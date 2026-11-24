import SwiftUI

@main
struct MinderIPTVApp: App {
    @StateObject private var store = PlaylistStore()
    @StateObject private var updater = Updater()

    var body: some Scene {
        WindowGroup(L("小满 IPTV")) {
            ContentView()
                .environmentObject(store)
                .environmentObject(updater)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button(L("检查更新…")) { Task { await updater.check(userInitiated: true) } }
                    .disabled(updater.busy)
            }
            CommandGroup(replacing: .appSettings) {
                Button(L("设置…")) { store.showSettings = true }
                    .keyboardShortcut(",", modifiers: .command)
            }
            CommandGroup(after: .newItem) {
                Button(L("立即更新频道列表")) { Task { await store.refresh() } }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
