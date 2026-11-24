import SwiftUI

enum SidebarItem: Hashable {
    case favorites, all, group(String)
}

struct ContentView: View {
    @EnvironmentObject var store: PlaylistStore
    @EnvironmentObject var updater: Updater
    @StateObject private var pc = PlayerController()
    @State private var sidebar: SidebarItem? = .group("📺央视频道")
    @State private var search = ""
    
    private var channels: [Channel] {
        let all = store.playlist.channels
        var list: [Channel]
        switch sidebar {
        case .favorites: list = all.filter { store.favorites.contains($0.id) }
        case .group(let g): list = all.filter { $0.group == g }
        default: list = all
        }
        if !search.isEmpty {
            list = (sidebar == .all ? all : list).filter { $0.name.localizedCaseInsensitiveContains(search) }
        }
        return list
    }

    @ViewBuilder
    private func groupSection(_ title: String, _ groups: [String]) -> some View {
        if !groups.isEmpty {
            Section(title) {
                ForEach(groups, id: \.self) { g in
                    HStack {
                        Text(Overseas.displayName(group: g))
                        Spacer()
                        Text("\(counts[g] ?? 0)").foregroundStyle(.secondary).font(.caption)
                    }.tag(SidebarItem.group(g))
                }
            }
        }
    }

    private var counts: [String: Int] {
        store.playlist.channels.reduce(into: [:]) { $0[$1.group, default: 0] += 1 }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $sidebar) {
                Section {
                    Label(L("收藏"), systemImage: "star.fill").tag(SidebarItem.favorites)
                    Label(L("全部频道"), systemImage: "square.grid.2x2").tag(SidebarItem.all)
                }
                groupSection(L("国内频道"), store.playlist.groups.filter {
                    !$0.hasPrefix(Overseas.tvPrefix) && !$0.hasPrefix(Overseas.radioPrefix) })
                groupSection(L("海外电视"), store.playlist.groups.filter { $0.hasPrefix(Overseas.tvPrefix) })
                groupSection(L("海外电台"), store.playlist.groups.filter { $0.hasPrefix(Overseas.radioPrefix) })
            }
            .navigationSplitViewColumnWidth(min: 170, ideal: 190)
            .safeAreaInset(edge: .bottom) { StatusFooter().padding(8) }
        } content: {
            List(channels) { c in
                ChannelRow(channel: c, playing: pc.channel?.id == c.id)
                    .contentShape(Rectangle())
                    .onTapGesture { pc.play(c) }
                    .contextMenu {
                        Button(store.favorites.contains(c.id) ? L("取消收藏") : L("加入收藏")) { store.toggleFavorite(c) }
                    }
            }
            .overlay {
                if channels.isEmpty {
                    ContentUnavailableView(store.isRefreshing ? L("正在加载频道…") : L("没有频道"),
                                           systemImage: "tv",
                                           description: Text(sidebar == .favorites ? L("右键频道可加入收藏") : ""))
                }
            }
            .searchable(text: $search, placement: .sidebar, prompt: Text(L("搜索频道")))
            .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } detail: {
            PlayerPane(pc: pc)
        }
        .toolbar {
            ToolbarItemGroup {
                if let c = pc.channel, c.sources.count > 1 {
                    Menu {
                        ForEach(c.sources.indices, id: \.self) { i in
                            Button {
                                pc.selectSource(i)
                            } label: {
                                if i == pc.sourceIndex { Label(L("线路 %d", i + 1), systemImage: "checkmark") }
                                else { Text(L("线路 %d", i + 1)) }
                            }
                        }
                    } label: { Label(L("线路 %d/%d", pc.sourceIndex + 1, c.sources.count), systemImage: "antenna.radiowaves.left.and.right") }
                    .help(L("切换线路"))
                }
                if let c = pc.channel {
                    Button { store.toggleFavorite(c) } label: {
                        Label(L("收藏"), systemImage: store.favorites.contains(c.id) ? "star.fill" : "star")
                    }.help(L("收藏当前频道"))
                }
                Button {
                    Task { await store.refresh() }
                } label: {
                    if store.isRefreshing { ProgressView().controlSize(.small) }
                    else { Label(L("立即更新"), systemImage: "arrow.clockwise") }
                }
                .help(L("立即更新频道列表 (⌘R)"))
                .disabled(store.isRefreshing)
                Button { store.showSettings = true } label: { Label(L("设置"), systemImage: "gearshape") }
            }
        }
        .sheet(isPresented: $store.showSettings) { SettingsView().environmentObject(store).environmentObject(updater) }
        .navigationTitle(pc.channel?.name ?? L("小满 IPTV"))
        .onChange(of: store.playlist.channels.count) {
            if case .group(let g) = sidebar, !store.playlist.groups.contains(g) {
                sidebar = store.playlist.groups.first.map { .group($0) } ?? .all
            }
        }
    }
}

struct ChannelRow: View {
    @EnvironmentObject var store: PlaylistStore
    let channel: Channel
    let playing: Bool
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: channel.logo) { img in
                img.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "tv").foregroundStyle(.secondary)
            }
            .frame(width: 44, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(channel.name).fontWeight(playing ? .semibold : .regular)
                Text(channel.isRadio ? L("电台") : L("%d 条线路", channel.sources.count)).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if store.favorites.contains(channel.id) {
                Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
            }
            if playing { Image(systemName: "speaker.wave.2.fill").foregroundStyle(.tint) }
        }
        .padding(.vertical, 2)
    }
}

struct PlayerPane: View {
    @ObservedObject var pc: PlayerController
    var body: some View {
        ZStack {
            Color.black
            if let c = pc.channel {
                PlayerView(player: pc.player)
                if c.isRadio {
                    VStack(spacing: 16) {
                        AsyncImage(url: c.logo) { img in
                            img.resizable().scaledToFit()
                        } placeholder: {
                            Image(systemName: "radio").font(.system(size: 72)).foregroundStyle(.white.opacity(0.7))
                        }
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        Text(c.name).font(.title2.bold()).foregroundStyle(.white).multilineTextAlignment(.center)
                        Text(Overseas.displayName(group: c.group)).foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(.bottom, 40)
                    .allowsHitTesting(false)
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "play.tv").font(.system(size: 56))
                    Text(L("从左侧选择频道开始观看")).font(.title3)
                }.foregroundStyle(.white.opacity(0.6))
            }
            if !pc.status.isEmpty {
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        if !pc.failed { ProgressView().controlSize(.small) }
                        Text(pc.status)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, 60)
                }
            }
        }
        .frame(minWidth: 480, minHeight: 300)
    }
}

struct StatusFooter: View {
    @EnvironmentObject var store: PlaylistStore
    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { _ in
            VStack(alignment: .leading, spacing: 3) {
                Text(L("%d 个频道", store.playlist.channels.count)).font(.caption.bold())
                if let d = store.lastFetch {
                    Text(L("上次更新 %@", d.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: Lang.locale))))
                }
                if let n = store.nextRefresh {
                    Text(L("下次自动更新 %@", n.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: Lang.locale))))
                } else if !store.autoRefresh {
                    Text(L("自动更新已关闭"))
                }
                if let g = store.playlist.generatedAt { Text(L("源生成于 %@", g)) }
                if let e = store.lastError {
                    Text(e).foregroundStyle(.red).lineLimit(3).help(e)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: PlaylistStore
    @EnvironmentObject var updater: Updater
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var tvSel: Set<String> = []
    @State private var radioSel: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L("设置")).font(.title2.bold())
            HStack {
                Picker(L("语言"), selection: Binding(get: { AppLanguage.saved }, set: { AppLanguage.apply($0) })) {
                    ForEach(AppLanguage.allCases) { Text($0.displayName).tag($0) }
                }
                .frame(width: 260)
                Text(L("切换语言后应用会自动重启")).font(.caption).foregroundStyle(.secondary)
            }
            HStack {
                Toggle(L("自动检查软件更新"), isOn: $updater.autoCheck)
                Spacer()
                Text(L("当前版本 %@", Updater.currentVersion)).font(.caption).foregroundStyle(.secondary)
                Button(L("立即检查")) { Task { await updater.check(userInitiated: true) } }.disabled(updater.busy)
            }
            if !updater.status.isEmpty { Text(updater.status).font(.caption) }
            Divider()
            Toggle(L("每 1 小时自动更新频道列表"), isOn: $store.autoRefresh)
            VStack(alignment: .leading, spacing: 6) {
                Text(L("直播源地址（每行一个，按顺序尝试，支持 M3U / TXT）")).font(.headline)
                Text(L("默认使用 Guovin/iptv-api 发布的结果。若你自己用 Docker 部署了 iptv-api，可填 http://localhost:8000/m3u"))
                    .font(.caption).foregroundStyle(.secondary)
                TextEditor(text: $text)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 80)
                    .border(.separator)
            }
            Divider()
            Toggle(L("海外电视（来自 iptv-org 开源项目）"), isOn: $store.overseasTVEnabled).font(.headline)
            CountryGrid(selection: $tvSel).disabled(!store.overseasTVEnabled)
            Toggle(L("海外电台（来自 Radio Browser，每国热门 80 个）"), isOn: $store.radioEnabled).font(.headline)
            CountryGrid(selection: $radioSel).disabled(!store.radioEnabled)
            Text(L("海外直播源由网友收集，部分可能失效或需要特殊网络才能访问。")).font(.caption).foregroundStyle(.secondary)
            if let s = store.activeSource {
                Text(L("当前使用：%@", s)).font(.caption).foregroundStyle(.secondary).textSelection(.enabled)
            }
            HStack {
                Button(L("恢复默认")) { text = PlaylistStore.defaultSources.joined(separator: "\n") }
                Spacer()
                Button(L("取消")) { dismiss() }
                Button(L("保存并更新")) {
                    let list = text.split(whereSeparator: \.isNewline)
                        .map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    store.sources = list.isEmpty ? PlaylistStore.defaultSources : list
                    store.tvCountries = Overseas.countries.map(\.iso).filter { tvSel.contains($0) }
                    store.radioCountries = Overseas.countries.map(\.iso).filter { radioSel.contains($0) }
                    dismiss()
                    Task { await store.refresh() }
                }.keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 680)
        .onAppear {
            text = store.sources.joined(separator: "\n")
            tvSel = Set(store.tvCountries)
            radioSel = Set(store.radioCountries)
        }
    }
}

struct CountryGrid: View {
    @Binding var selection: Set<String>
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 6), spacing: 6) {
            ForEach(Overseas.countries) { c in
                Toggle(c.label, isOn: Binding(
                    get: { selection.contains(c.iso) },
                    set: { if $0 { selection.insert(c.iso) } else { selection.remove(c.iso) } }
                ))
                .toggleStyle(.checkbox)
            }
        }
    }
}
