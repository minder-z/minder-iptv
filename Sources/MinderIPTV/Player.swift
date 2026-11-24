import AVKit
import SwiftUI

/// 播放控制：失败或 12 秒未起播时自动切换到下一条线路
@MainActor
final class PlayerController: ObservableObject {
    let player = AVPlayer()
    @Published private(set) var channel: Channel?
    @Published private(set) var sourceIndex = 0
    @Published private(set) var status: String = ""
    @Published private(set) var isPlaying = false
    @Published private(set) var failed = false

    private var observations: [NSKeyValueObservation] = []
    private var timeout: Task<Void, Never>?
    private var tried: Set<Int> = []

    func play(_ c: Channel, source: Int = 0) {
        if channel?.id != c.id { tried = [] }
        channel = c
        sourceIndex = min(source, max(c.sources.count - 1, 0))
        start()
    }

    func selectSource(_ i: Int) {
        guard let c = channel else { return }
        tried = []
        play(c, source: i)
    }

    func stop() {
        timeout?.cancel()
        player.replaceCurrentItem(with: nil)
        channel = nil
        isPlaying = false
        status = ""
    }

    private func start() {
        guard let c = channel, c.sources.indices.contains(sourceIndex) else { return }
        tried.insert(sourceIndex)
        let src = c.sources[sourceIndex]
        status = L("正在连接 线路 %d/%d…", sourceIndex + 1, c.sources.count)
        failed = false
        isPlaying = false

        var headers: [String: String] = [:]
        if let ua = src.userAgent { headers["User-Agent"] = ua }
        if let r = src.referrer { headers["Referer"] = r }
        let asset = AVURLAsset(url: src.url, options: headers.isEmpty ? nil : ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let item = AVPlayerItem(asset: asset)
        item.preferredForwardBufferDuration = 4

        observations = [
            item.observe(\.status) { [weak self] item, _ in
                Task { @MainActor in
                    if item.status == .failed { self?.failover(reason: item.error?.localizedDescription) }
                }
            },
            player.observe(\.timeControlStatus) { [weak self] p, _ in
                Task { @MainActor in
                    guard let self else { return }
                    if p.timeControlStatus == .playing {
                        self.isPlaying = true
                        self.status = ""
                        self.timeout?.cancel()
                    } else if p.timeControlStatus == .waitingToPlayAtSpecifiedRate, self.isPlaying {
                        self.status = L("缓冲中…")
                    }
                }
            },
        ]
        player.replaceCurrentItem(with: item)
        player.play()

        timeout?.cancel()
        let idx = sourceIndex
        timeout = Task { [weak self] in
            try? await Task.sleep(for: .seconds(12))
            guard !Task.isCancelled, let self, self.sourceIndex == idx, !self.isPlaying else { return }
            self.failover(reason: L("连接超时"))
        }
    }

    private func failover(reason: String?) {
        guard let c = channel else { return }
        if let next = c.sources.indices.first(where: { !tried.contains($0) && $0 > sourceIndex })
            ?? c.sources.indices.first(where: { !tried.contains($0) }) {
            sourceIndex = next
            start()
        } else {
            timeout?.cancel()
            isPlaying = false
            failed = true
            status = L("所有线路都无法播放（%@），请换个频道或稍后刷新列表", reason ?? L("未知错误"))
        }
    }
}

/// 原生 AVPlayerView，支持全屏、画中画
struct PlayerView: NSViewRepresentable {
    let player: AVPlayer
    func makeNSView(context: Context) -> AVPlayerView {
        let v = AVPlayerView()
        v.player = player
        v.controlsStyle = .floating
        v.allowsPictureInPicturePlayback = true
        v.showsFullScreenToggleButton = true
        return v
    }
    func updateNSView(_ v: AVPlayerView, context: Context) {
        if v.player !== player { v.player = player }
    }
}
