import Foundation
import SwiftUI

@MainActor
final class PlaylistStore: ObservableObject {
    static let defaultSources = [
        "https://guovin.github.io/iptv-api/result.m3u",
        "https://cdn.jsdelivr.net/gh/Guovin/iptv-api@gd/output/result.m3u",
        "https://raw.githubusercontent.com/Guovin/iptv-api/gd/output/result.m3u",
    ]
    static let refreshInterval: TimeInterval = 3600

    /// 合并后的完整列表（国内 + 海外电视 + 海外电台）
    @Published private(set) var playlist = Playlist(channels: [], groups: [], generatedAt: nil)
    @Published private(set) var isRefreshing = false
    @Published private(set) var lastFetch: Date?
    @Published private(set) var lastError: String?
    @Published private(set) var activeSource: String?
    @Published var favorites: Set<String> { didSet { save(Array(favorites), "favorites") } }
    @Published var sources: [String] { didSet { save(sources, "sources") } }
    @Published var autoRefresh: Bool { didSet { UserDefaults.standard.set(autoRefresh, forKey: "autoRefresh") } }
    @Published var overseasTVEnabled: Bool { didSet { UserDefaults.standard.set(overseasTVEnabled, forKey: "overseasTV"); rebuild() } }
    @Published var radioEnabled: Bool { didSet { UserDefaults.standard.set(radioEnabled, forKey: "radio"); rebuild() } }
    @Published var tvCountries: [String] { didSet { save(tvCountries, "tvCountries") } }
    @Published var radioCountries: [String] { didSet { save(radioCountries, "radioCountries") } }

    private var domestic = Playlist(channels: [], groups: [], generatedAt: nil)
    private var overseasTV: [Channel] = []
    private var radio: [Channel] = []

    private var ticker: Timer?
    /// 失败时用于提前重试
    @Published private var retryAt: Date?

    var nextRefresh: Date? {
        guard autoRefresh else { return nil }
        if let r = retryAt { return r }
        return lastFetch?.addingTimeInterval(Self.refreshInterval)
    }

    init() {
        let d = UserDefaults.standard
        favorites = Set(d.stringArray(forKey: "favorites") ?? [])
        let saved = d.stringArray(forKey: "sources") ?? []
        sources = saved.isEmpty ? Self.defaultSources : saved
        autoRefresh = d.object(forKey: "autoRefresh") as? Bool ?? true
        overseasTVEnabled = d.object(forKey: "overseasTV") as? Bool ?? true
        radioEnabled = d.object(forKey: "radio") as? Bool ?? true
        tvCountries = d.stringArray(forKey: "tvCountries") ?? Overseas.defaultTV
        radioCountries = d.stringArray(forKey: "radioCountries") ?? Overseas.defaultRadio
        lastFetch = d.object(forKey: "lastFetch") as? Date
        loadCache()
        startTicker()
        Task { await refresh() }
    }

    // MARK: 定时：每 30 秒检查一次是否已满 1 小时（休眠唤醒后也能及时补更新）
    private func startTicker() {
        ticker = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.autoRefresh, !self.isRefreshing else { return }
                if let next = self.nextRefresh, Date() < next { return }
                await self.refresh()
            }
        }
    }

    // MARK: 刷新：国内源依次尝试；海外电视、电台同时拉取。任何一项失败都保留旧数据
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        var errors: [String] = []

        let tvIsos = overseasTVEnabled ? tvCountries : []
        let radioIsos = radioEnabled ? radioCountries : []
        async let tvTask: Result<[Channel], Error>? = tvIsos.isEmpty ? nil : capture { try await Overseas.fetchTV(isos: tvIsos) }
        async let radioTask: Result<[Channel], Error>? = radioIsos.isEmpty ? nil : capture { try await Overseas.fetchRadio(isos: radioIsos) }

        var domesticOK = false
        for s in sources {
            guard let url = URL(string: s.trimmingCharacters(in: .whitespaces)) else { continue }
            do {
                let data = try await Overseas.getData(url)
                let parsed = PlaylistParser.parse(String(decoding: data, as: UTF8.self))
                guard !parsed.channels.isEmpty else { throw URLError(.cannotParseResponse) }
                domestic = parsed
                activeSource = s
                try? data.write(to: Self.cacheURL("playlist.m3u"))
                domesticOK = true
                break
            } catch {
                errors.append("\(url.host ?? s): \(error.localizedDescription)")
            }
        }

        switch await tvTask {
        case .success(let list)?:
            overseasTV = list
            Self.writeJSON(list, "overseas_tv.json")
        case .failure(let e)?: errors.append("海外电视: \(e.localizedDescription)")
        case nil: break
        }
        switch await radioTask {
        case .success(let list)?:
            radio = list
            Self.writeJSON(list, "radio.json")
        case .failure(let e)?: errors.append("海外电台: \(e.localizedDescription)")
        case nil: break
        }

        rebuild()
        if domesticOK {
            lastFetch = Date()
            UserDefaults.standard.set(lastFetch, forKey: "lastFetch")
            retryAt = nil
            lastError = errors.isEmpty ? nil : "部分更新失败（已保留旧列表）\n" + errors.joined(separator: "\n")
        } else {
            lastError = "更新失败（已保留旧列表）\n" + errors.joined(separator: "\n")
            // 失败后 5 分钟再试，而不是等满 1 小时
            retryAt = Date().addingTimeInterval(300)
        }
    }

    private nonisolated func capture(_ op: @Sendable () async throws -> [Channel]) async -> Result<[Channel], Error> {
        do { return .success(try await op()) } catch { return .failure(error) }
    }

    /// 把三部分合成一个列表；海外部分只保留当前勾选的国家
    private func rebuild() {
        let tvGroups = Set(Overseas.countries.filter { tvCountries.contains($0.iso) }.map { Overseas.tvPrefix + $0.zh })
        let radioGroups = Set(Overseas.countries.filter { radioCountries.contains($0.iso) }.map { Overseas.radioPrefix + $0.zh + "电台" })
        var channels = domestic.channels
        if overseasTVEnabled { channels += overseasTV.filter { tvGroups.contains($0.group) } }
        if radioEnabled { channels += radio.filter { radioGroups.contains($0.group) } }
        var groups: [String] = []
        var seen = Set<String>()
        for c in channels where seen.insert(c.group).inserted { groups.append(c.group) }
        playlist = Playlist(channels: channels, groups: groups, generatedAt: domestic.generatedAt)
    }

    func toggleFavorite(_ c: Channel) {
        if favorites.contains(c.id) { favorites.remove(c.id) } else { favorites.insert(c.id) }
    }

    // MARK: 缓存
    private static func cacheURL(_ name: String) -> URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MinderIPTV", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(name)
    }

    private static func writeJSON(_ list: [Channel], _ name: String) {
        if let data = try? JSONEncoder().encode(list) { try? data.write(to: cacheURL(name)) }
    }

    private static func readJSON(_ name: String) -> [Channel] {
        guard let data = try? Data(contentsOf: cacheURL(name)) else { return [] }
        return (try? JSONDecoder().decode([Channel].self, from: data)) ?? []
    }

    private func loadCache() {
        if let data = try? Data(contentsOf: Self.cacheURL("playlist.m3u")) {
            domestic = PlaylistParser.parse(String(decoding: data, as: UTF8.self))
        }
        overseasTV = Self.readJSON("overseas_tv.json")
        radio = Self.readJSON("radio.json")
        rebuild()
    }

    private func save(_ v: [String], _ key: String) { UserDefaults.standard.set(v, forKey: key) }
}
