import Foundation

/// 一条播放线路（同一频道可能有多条）
struct StreamSource: Hashable, Codable {
    var url: URL
    var userAgent: String?
    var referrer: String?
}

struct Channel: Identifiable, Hashable, Codable {
    var id: String { group + "|" + name }
    var name: String
    var group: String
    var logo: URL?
    var sources: [StreamSource]
    var isRadio: Bool = false
}

struct Playlist: Codable {
    var channels: [Channel]
    var groups: [String]
    /// iptv-api 结果里写的生成时间
    var generatedAt: String?
}

enum PlaylistParser {
    static let updateGroupMarker = "更新时间"

    /// 解析 M3U（iptv-api 的 result.m3u），同组同名频道合并为多线路
    static func parseM3U(_ text: String) -> Playlist {
        var order: [String] = []
        var map: [String: Channel] = [:]
        var groups: [String] = []
        var generatedAt: String?

        var pending: (name: String, group: String, logo: URL?)?
        var ua: String?
        var ref: String?

        for raw in text.split(whereSeparator: \.isNewline) {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            if line.hasPrefix("#EXTINF") {
                let attrs = attributes(line)
                let name = line.range(of: ",", options: .backwards).map {
                    String(line[$0.upperBound...]).trimmingCharacters(in: .whitespaces)
                } ?? (attrs["tvg-name"] ?? "未命名")
                let group = attrs["group-title"] ?? "其他"
                pending = (name, group, attrs["tvg-logo"].flatMap(URL.init(string:)))
                ua = nil; ref = nil
            } else if line.hasPrefix("#EXTVLCOPT:") {
                let opt = line.dropFirst("#EXTVLCOPT:".count)
                if opt.hasPrefix("http-user-agent=") { ua = String(opt.dropFirst("http-user-agent=".count)) }
                if opt.hasPrefix("http-referrer=") { ref = String(opt.dropFirst("http-referrer=".count)) }
            } else if line.hasPrefix("#") {
                continue
            } else if let p = pending, let url = URL(string: line) {
                pending = nil
                if p.group.contains(updateGroupMarker) {
                    generatedAt = p.name
                    continue
                }
                let src = StreamSource(url: url, userAgent: ua, referrer: ref)
                let key = p.group + "|" + p.name
                if var c = map[key] {
                    if !c.sources.contains(src) { c.sources.append(src) }
                    if c.logo == nil { c.logo = p.logo }
                    map[key] = c
                } else {
                    map[key] = Channel(name: p.name, group: p.group, logo: p.logo, sources: [src])
                    order.append(key)
                    if !groups.contains(p.group) { groups.append(p.group) }
                }
            }
        }
        return Playlist(channels: order.compactMap { map[$0] }, groups: groups, generatedAt: generatedAt)
    }

    /// 解析 TXT（"分组,#genre#" + "频道,地址"）
    static func parseTXT(_ text: String) -> Playlist {
        var m3u = "#EXTM3U\n"
        var group = "其他"
        for raw in text.split(whereSeparator: \.isNewline) {
            let parts = raw.split(separator: ",", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            if parts[1] == "#genre#" { group = parts[0]; continue }
            for u in parts[1].split(separator: "#") {
                m3u += "#EXTINF:-1 group-title=\"\(group)\",\(parts[0])\n\(u)\n"
            }
        }
        return parseM3U(m3u)
    }

    static func parse(_ text: String) -> Playlist {
        text.contains("#EXTINF") ? parseM3U(text) : parseTXT(text)
    }

    private static func attributes(_ line: String) -> [String: String] {
        var result: [String: String] = [:]
        let pattern = #"([\w-]+)="([^"]*)""#
        guard let re = try? NSRegularExpression(pattern: pattern) else { return result }
        let ns = line as NSString
        for m in re.matches(in: line, range: NSRange(location: 0, length: ns.length)) {
            result[ns.substring(with: m.range(at: 1))] = ns.substring(with: m.range(at: 2))
        }
        return result
    }
}
