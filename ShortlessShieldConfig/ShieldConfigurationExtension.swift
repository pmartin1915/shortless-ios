import ManagedSettingsUI
import ManagedSettings
import UIKit

/// Provides a custom branded shield screen when blocked apps are opened.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        makeConfiguration()
    }

    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        makeConfiguration()
    }

    private func makeConfiguration() -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            backgroundColor: UIColor(red: 0.10, green: 0.10, blue: 0.18, alpha: 1.0), // #1a1a2e
            icon: UIImage(systemName: "shield.checkered"),
            title: ShieldConfiguration.Label(
                text: "Blocked by Shortless",
                color: UIColor.white
            ),
            subtitle: ShieldConfiguration.Label(
                text: "This app is blocked during your focus schedule. Stay focused!",
                color: UIColor(red: 0.88, green: 0.88, blue: 0.88, alpha: 1.0) // #e0e0e0
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "OK",
                color: UIColor.white
            ),
            primaryButtonBackgroundColor: UIColor(red: 0.23, green: 0.73, blue: 0.71, alpha: 1.0) // #3ABAB4
        )
    }
}
