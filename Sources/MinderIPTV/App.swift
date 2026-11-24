import SwiftUI

@main
struct MinderIPTVApp: App {
    @StateObject private var store = PlaylistStore()

    var body: some Scene {
        WindowGroup("小满 IPTV") {
            ContentView()
                .environmentObject(store)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("立即更新频道列表") { Task { await store.refresh() } }
                    .keyboardShortcut("r", modifiers: .command)
            }
        }
    }
}
