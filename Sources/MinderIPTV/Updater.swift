import AppKit
import Foundation

/// 软件自更新：查询 GitHub 最新 Release，有新版本时下载 zip、替换自身并重启
@MainActor
final class Updater: ObservableObject {
    static let repo = "minder-z/minder-iptv"
    static let checkInterval: TimeInterval = 24 * 3600

    @Published var autoCheck: Bool { didSet { UserDefaults.standard.set(autoCheck, forKey: "autoCheckUpdates") } }
    @Published private(set) var busy = false
    @Published private(set) var status = ""

    private var ticker: Timer?

    static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

    init() {
        autoCheck = UserDefaults.standard.object(forKey: "autoCheckUpdates") as? Bool ?? true
        // 启动 10 秒后检查一次，之后每小时看一下是否满 24 小时
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(10))
            await self?.autoCheckIfDue()
        }
        ticker = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { @MainActor in await self?.autoCheckIfDue() }
        }
    }

    private func autoCheckIfDue() async {
        guard autoCheck else { return }
        if let last = UserDefaults.standard.object(forKey: "lastUpdateCheck") as? Date,
           Date().timeIntervalSince(last) < Self.checkInterval { return }
        await check(userInitiated: false)
    }

    private struct Release: Decodable {
        struct Asset: Decodable { let name: String; let browser_download_url: URL }
        let tag_name: String
        let body: String?
        let draft: Bool
        let prerelease: Bool
        let assets: [Asset]
    }

    func check(userInitiated: Bool) async {
        guard !busy else { return }
        busy = true
        defer { busy = false }
        do {
            var req = URLRequest(url: URL(string: "https://api.github.com/repos/\(Self.repo)/releases/latest")!,
                                 cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
            req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            req.setValue("MinderIPTV/\(Self.currentVersion)", forHTTPHeaderField: "User-Agent")
            let (data, resp) = try await URLSession.shared.data(for: req)
            if let http = resp as? HTTPURLResponse, http.statusCode != 200 {
                throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
            }
            let rel = try JSONDecoder().decode(Release.self, from: data)
            UserDefaults.standard.set(Date(), forKey: "lastUpdateCheck")
            let latest = rel.tag_name.trimmingCharacters(in: CharacterSet(charactersIn: "vV"))

            guard Self.isNewer(latest, than: Self.currentVersion),
                  let asset = rel.assets.first(where: { $0.name.hasSuffix(".zip") }) else {
                if userInitiated {
                    alert(L("已是最新版本"), L("当前版本 %@ 已是最新。", Self.currentVersion))
                }
                return
            }

            let a = NSAlert()
            a.messageText = L("发现新版本 %@", latest)
            var info = L("你当前使用的是 %@。是否现在下载并安装？", Self.currentVersion)
            if let notes = rel.body?.trimmingCharacters(in: .whitespacesAndNewlines), !notes.isEmpty {
                info += "\n\n" + String(notes.prefix(800))
            }
            a.informativeText = info
            a.addButton(withTitle: L("下载并安装"))
            a.addButton(withTitle: L("以后再说"))
            // 测试用：设置环境变量 MINDERIPTV_UPDATE_AUTOACCEPT=1 时跳过确认框
            let autoAccept = ProcessInfo.processInfo.environment["MINDERIPTV_UPDATE_AUTOACCEPT"] == "1"
            if !autoAccept {
                NSApp.activate(ignoringOtherApps: true)
                guard a.runModal() == .alertFirstButtonReturn else { return }
            }
            do {
                try await install(from: asset.browser_download_url)
            } catch {
                status = ""
                alert(L("更新安装失败：%@", error.localizedDescription), "")
            }
        } catch {
            if userInitiated { alert(L("检查更新失败"), error.localizedDescription) }
        }
    }

    /// 下载 zip → 解压 → 等本进程退出后替换 .app → 重新打开
    private func install(from url: URL) async throws {
        status = L("正在下载更新…")
        let (tmpZip, _) = try await URLSession.shared.download(from: url)
        let work = FileManager.default.temporaryDirectory.appendingPathComponent("MinderIPTV-update-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: work, withIntermediateDirectories: true)
        let zip = work.appendingPathComponent("update.zip")
        try FileManager.default.moveItem(at: tmpZip, to: zip)

        try run("/usr/bin/ditto", ["-x", "-k", zip.path, work.path])
        guard let newApp = try FileManager.default.contentsOfDirectory(at: work, includingPropertiesForKeys: nil)
            .first(where: { $0.pathExtension == "app" }) else {
            throw URLError(.cannotDecodeContentData, userInfo: [NSLocalizedDescriptionKey: "zip 中没有 .app"])
        }

        let target = Bundle.main.bundleURL
        guard FileManager.default.isWritableFile(atPath: target.deletingLastPathComponent().path) else {
            throw CocoaError(.fileWriteNoPermission)
        }

        // 交给 shell：等当前进程退出，替换，去掉隔离标记，重新打开
        let script = """
        while kill -0 "$1" 2>/dev/null; do sleep 0.3; done
        rm -rf "$3" && mv "$2" "$3" && xattr -dr com.apple.quarantine "$3" 2>/dev/null
        open "$3"
        rm -rf "$4"
        """
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/bin/sh")
        p.arguments = ["-c", script, "sh", String(ProcessInfo.processInfo.processIdentifier),
                       newApp.path, target.path, work.path]
        try p.run()
        NSApp.terminate(nil)
    }

    private func run(_ exe: String, _ args: [String]) throws {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: exe)
        p.arguments = args
        try p.run()
        p.waitUntilExit()
        if p.terminationStatus != 0 {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    private func alert(_ title: String, _ text: String) {
        let a = NSAlert()
        a.messageText = title
        a.informativeText = text
        a.addButton(withTitle: L("好"))
        NSApp.activate(ignoringOtherApps: true)
        a.runModal()
    }

    static func isNewer(_ a: String, than b: String) -> Bool {
        let pa = a.split(separator: ".").map { Int($0) ?? 0 }
        let pb = b.split(separator: ".").map { Int($0) ?? 0 }
        for i in 0..<max(pa.count, pb.count) {
            let x = i < pa.count ? pa[i] : 0, y = i < pb.count ? pb[i] : 0
            if x != y { return x > y }
        }
        return false
    }
}
