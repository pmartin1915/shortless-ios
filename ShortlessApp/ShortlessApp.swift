import SwiftUI
import ShortlessKit

@main
struct ShortlessApp: App {
    @StateObject private var settings = SettingsStore()
    @StateObject private var blockCount = BlockCountStore()

    var body: some Scene {
        WindowGroup {
            DashboardView(settings: settings, blockCount: blockCount)
        }
    }
}
