import Foundation

struct Country: Identifiable, Hashable {
    var id: String { iso }
    let iso: String      // radio-browser 用的国家代码
    let en: String       // iptv-org index.country.m3u 里的 group-title
    let zh: String
    let flag: String
    var label: String { "\(flag) \(L(zh))" }
}

enum Overseas {
    static let tvPrefix = "🌍 "
    static let radioPrefix = "📻 "

    /// 分组的显示名：海外分组按当前语言显示国家名（内部 ID 仍用中文，收藏不受影响）
    static func displayName(group g: String) -> String {
        if g.hasPrefix(tvPrefix) { return tvPrefix + L(String(g.dropFirst(tvPrefix.count))) }
        if g.hasPrefix(radioPrefix), g.hasSuffix("电台") {
            let zh = String(g.dropFirst(radioPrefix.count).dropLast(2))
            return radioPrefix + L("%@电台", L(zh))
        }
        return g
    }

    static let countries: [Country] = [
        .init(iso: "US", en: "United States", zh: "美国", flag: "🇺🇸"),
        .init(iso: "GB", en: "United Kingdom", zh: "英国", flag: "🇬🇧"),
        .init(iso: "JP", en: "Japan", zh: "日本", flag: "🇯🇵"),
        .init(iso: "KR", en: "South Korea", zh: "韩国", flag: "🇰🇷"),
        .init(iso: "HK", en: "Hong Kong", zh: "香港", flag: "🇭🇰"),
        .init(iso: "TW", en: "Taiwan", zh: "台湾", flag: "🇹🇼"),
        .init(iso: "SG", en: "Singapore", zh: "新加坡", flag: "🇸🇬"),
        .init(iso: "MY", en: "Malaysia", zh: "马来西亚", flag: "🇲🇾"),
        .init(iso: "TH", en: "Thailand", zh: "泰国", flag: "🇹🇭"),
        .init(iso: "IN", en: "India", zh: "印度", flag: "🇮🇳"),
        .init(iso: "AU", en: "Australia", zh: "澳大利亚", flag: "🇦🇺"),
        .init(iso: "CA", en: "Canada", zh: "加拿大", flag: "🇨🇦"),
        .init(iso: "FR", en: "France", zh: "法国", flag: "🇫🇷"),
        .init(iso: "DE", en: "Germany", zh: "德国", flag: "🇩🇪"),
        .init(iso: "IT", en: "Italy", zh: "意大利", flag: "🇮🇹"),
        .init(iso: "ES", en: "Spain", zh: "西班牙", flag: "🇪🇸"),
        .init(iso: "RU", en: "Russia", zh: "俄罗斯", flag: "🇷🇺"),
    ]
    static let defaultTV = ["US", "GB", "JP", "KR", "SG", "FR", "DE"]
    static let defaultRadio = ["US", "GB", "JP", "KR", "FR", "DE", "AU", "CA"]

    // MARK: 海外电视：iptv-org 按国家分组的总表
    static let tvURL = URL(string: "https://iptv-org.github.io/iptv/index.country.m3u")!

    static func fetchTV(isos: [String]) async throws -> [Channel] {
        let text = try await get(tvURL)
        let wanted = Dictionary(uniqueKeysWithValues: countries.filter { isos.contains($0.iso) }.map { ($0.en, $0) })
        let parsed = PlaylistParser.parseM3U(text)
        var rank: [String: Int] = [:]
        for (i, c) in countries.enumerated() { rank[tvPrefix + c.zh] = i }
        let mapped = parsed.channels.compactMap { c -> Channel? in
            guard let country = wanted[c.group] else { return nil }
            var c = c
            c.group = tvPrefix + country.zh
            return c
        }
        // 按国家表顺序排列，国家内部保持原顺序
        return mapped.enumerated()
            .sorted { (rank[$0.element.group] ?? 0, $0.offset) < (rank[$1.element.group] ?? 0, $1.offset) }
            .map(\.element)
    }

    // MARK: 海外电台：radio-browser 每个国家点击量最高的电台
    private struct Station: Decodable {
        let name: String
        let url_resolved: String
        let favicon: String
        let codec: String
        let bitrate: Int?
    }

    private static let radioHosts = [
        "https://de1.api.radio-browser.info",
        "https://fi1.api.radio-browser.info",
        "https://all.api.radio-browser.info",
    ]

    static func fetchRadio(isos: [String], perCountry: Int = 80) async throws -> [Channel] {
        var all: [Channel] = []
        var lastError: Error?
        for c in countries where isos.contains(c.iso) {
            for host in radioHosts {
                let url = URL(string: "\(host)/json/stations/bycountrycodeexact/\(c.iso)?order=clickcount&reverse=true&limit=\(perCountry)&hidebroken=true")!
                do {
                    let data = try await getData(url)
                    let stations = try JSONDecoder().decode([Station].self, from: data)
                    var seen = Set<String>()
                    for s in stations {
                        let name = s.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty, seen.insert(name).inserted,
                              let u = URL(string: s.url_resolved), u.scheme?.hasPrefix("http") == true else { continue }
                        all.append(Channel(name: name, group: radioPrefix + c.zh + "电台",
                                           logo: URL(string: s.favicon), sources: [StreamSource(url: u)],
                                           isRadio: true))
                    }
                    lastError = nil
                    break
                } catch { lastError = error }
            }
        }
        if all.isEmpty, let e = lastError { throw e }
        return all
    }

    // MARK: 网络
    static func getData(_ url: URL) async throws -> Data {
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        req.setValue("MinderIPTV/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
        let (data, resp) = try await URLSession.shared.data(for: req)
        if let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
        }
        return data
    }

    static func get(_ url: URL) async throws -> String {
        String(decoding: try await getData(url), as: UTF8.self)
    }
}
