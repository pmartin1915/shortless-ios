import SafariServices
import ShortlessKit

/// Handles native messaging between Safari Web Extension content scripts and the app.
/// Content scripts send messages via `browser.runtime.sendNativeMessage()`.
final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        guard let item = context.inputItems.first as? NSExtensionItem,
              let message = item.userInfo?[SFExtensionMessageKey] as? [String: Any],
              let type = message["type"] as? String else {
            context.completeRequest(returningItems: nil)
            return
        }

        let settings = SettingsStore()
        let blockCount = BlockCountStore()

        switch type {
        case "GET_PLATFORM_STATE":
            handleGetPlatformState(message: message, settings: settings, context: context)

        case "BLOCK_COUNT_INCREMENT":
            handleBlockCountIncrement(message: message, blockCount: blockCount, context: context)

        default:
            context.completeRequest(returningItems: nil)
        }
    }

    private func handleGetPlatformState(
        message: [String: Any],
        settings: SettingsStore,
        context: NSExtensionContext
    ) {
        guard let platformString = message["platform"] as? String,
              let platform = Platform(rawValue: platformString) else {
            respond(with: ["enabled": true], context: context)
            return
        }

        let enabled = settings.isEnabled(platform)
        respond(with: ["enabled": enabled], context: context)
    }

    private func handleBlockCountIncrement(
        message: [String: Any],
        blockCount: BlockCountStore,
        context: NSExtensionContext
    ) {
        let count = message["count"] as? Int ?? 1
        blockCount.increment(by: count)
        respond(with: ["success": true], context: context)
    }

    private func respond(with response: [String: Any], context: NSExtensionContext) {
        let item = NSExtensionItem()
        item.userInfo = [SFExtensionMessageKey: response]
        context.completeRequest(returningItems: [item])
    }
}
