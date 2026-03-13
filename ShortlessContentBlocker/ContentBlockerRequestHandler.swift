import Foundation
import ShortlessKit

final class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let data: Data
        do {
            let store = SettingsStore()
            let enabled = store.enabledPlatforms
            data = try ContentBlockerRuleGenerator.generateJSON(for: enabled)
        } catch {
            data = "[]".data(using: .utf8)!
        }

        let itemProvider = NSItemProvider(item: data as NSData,
                                          typeIdentifier: "public.json")
        let item = NSExtensionItem()
        item.attachments = [itemProvider]

        context.completeRequest(returningItems: [item])
    }
}
