# explore results

An exploration of the `shortless-ios` project codebase has been performed. The following report details the project's architecture, dependencies, and key patterns.

### Report

**To:** Perry Martin (pmartin1915)
**From:** `gemini-2.5-pro`
**Date:** 2026-04-25
**Subject:** Codebase Exploration: shortless-ios

### 1. Executive Summary

The `shortless-ios` project is a well-structured, multi-target iOS application built in Swift. It leverages a modern, declarative project setup using XcodeGen. The architecture is centered around a main application that acts as a container for numerous specialized app extensions, each handling a distinct piece of functionality (e.g., Safari blocking, Screen Time integration, Widgets).

A local Swift Package, `ShortlessKit`, serves as a shared core, providing common logic, data models, and constants to all targets. This is a clean and effective pattern that minimizes code duplication. Communication between the main app and its extensions is primarily handled through `UserDefaults` within a shared App Group, a standard and effective pattern for this architecture.

### 2. Build System & Project Configuration

The project's structure is defined declaratively in `project.yml` and generated into an `.xcodeproj` file using XcodeGen. This is a best practice for managing complex projects, as it keeps the project configuration version-controlled, human-readable, and easy to modify.

-   **Source of Truth:** `project.yml`
-   **Platform:** iOS 16.0+
-   **Language:** Swift 5.9
-   **Versioning:** 3.0.0 (Build 14)

### 3. Target Architecture & Dependencies

The project is composed of a main application target and seven extension targets, plus a unit test target. All targets (except `ShortlessShieldConfig` and `ShortlessTests`'s dependency on the main app) depend on the `ShortlessKit` local package for shared code.

| Target Name               | Type                | Purpose & Key Responsibilities                                                                                             | Dependencies               |
| ------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| **Shortless**             | `application`       | The main application container. Provides the primary user interface for settings and onboarding. Embeds all app extensions. | `ShortlessKit`, all extensions |
| **ShortlessKit**          | `package`           | **Shared Core Logic.** Contains shared data models (`ScheduleRule`), constants (`SettingsStore`), and business logic.        | -                          |
| **ShortlessContentBlocker** | `app-extension`     | Implements Safari's declarative content blocking rules (`com.apple.Safari.content-blocker`).                             | `ShortlessKit`             |
| **ShortlessSafariExtension**| `app-extension`     | Implements a Safari Web Extension (`com.apple.Safari.web-extension`) for more dynamic blocking and interaction.          | `ShortlessKit`             |
| **ShortlessVPNExtension**   | `app-extension`     | Provides system-level blocking via a Packet Tunnel Provider (`com.apple.networkextension.packet-tunnel`).                | `ShortlessKit`             |
| **ShortlessWidget**         | `app-extension`     | Displays app data (e.g., block count, streak) on the Home Screen using WidgetKit.                                          | `ShortlessKit`             |
| **ShortlessActivityMonitor**| `app-extension`     | Enforces Screen Time schedules using the Device Activity Monitor API (`com.apple.deviceactivity.monitor`).                 | `ShortlessKit`             |
| **ShortlessShieldConfig**   | `app-extension`     | Provides a custom user interface when a user attempts to open a blocked app (`com.apple.shieldconfiguration`).           | -                          |
| **ShortlessTests**          | `bundle.unit-test`  | Contains unit tests for the application logic.                                                                             | `Shortless`, `ShortlessKit`  |

### 4. Key Architectural Patterns

#### 4.1. Shared Logic via Local Swift Package

The use of the `ShortlessKit` local package is the most significant architectural decision. It effectively decouples shared components from any single target.
-   **Centralized Constants:** As seen in `DeviceActivityMonitorExtension.swift`, constants like `SettingsStore.appGroupID`, `SettingsStore.scheduleKey`, and `DeviceActivityName.shortlessFocus` are defined in `ShortlessKit`, ensuring consistency across the app and its extensions.
-   **Shared Models:** Data models like `ScheduleRule` and `FamilyActivitySelection` are decoded from `UserDefaults` in extensions, indicating they are defined and shared via `ShortlessKit`.
-   **Maintainability:** This pattern prevents code duplication and ensures that a change to a shared model or setting key is immediately reflected across all consuming targets.

#### 4.2. Inter-Target Communication via App Group

Communication between the main app and its various extensions is achieved via a shared `UserDefaults` container, enabled by an App Group.

-   **Mechanism:** An instance of `UserDefaults(suiteName: SettingsStore.appGroupID)` is used to read and write settings.
-   **Data Flow:**
    1.  The **main app (`ShortlessApp`)** writes user preferences (e.g., blocking mode, schedule, selected apps for blocking) to the shared `UserDefaults`.
    2.  The **extensions** (e.g., `ShortlessActivityMonitor`) read these preferences from `UserDefaults` to perform their tasks. For example, the monitor checks the schedule and the list of apps to block before applying shields.
-   **Example:** The `DeviceActivityMonitorExtension.swift` file clearly demonstrates this by reading `SettingsStore.scheduleKey`, `SettingsStore.appBlockerSelectionKey`, and `SettingsStore.blockingModeKey` to make decisions.

#### 4.3. Screen Time Integration

The project correctly implements the three key components of the Screen Time API:
1.  **FamilyControls (in Main App):** The main app uses this framework to present the app selection picker to the user. The resulting `FamilyActivitySelection` is saved to `UserDefaults`.
2.  **DeviceActivityMonitor (`ShortlessActivityMonitor`):** This extension runs in the background, triggered by the system at the start and end of scheduled `DeviceActivity` intervals. It reads the user's selection from `UserDefaults` and applies blocking rules.
3.  **ManagedSettings (`ShortlessActivityMonitor` & `ShortlessShieldConfig`):** The monitor uses the `ManagedSettingsStore` to apply "shields" to applications and categories. The `ShortlessShieldConfig` extension provides the custom UI for these shields.

### 5. Recommendations

The current architecture is robust, scalable, and follows modern iOS development best practices.
1.  **Formalize `UserDefaults` Contracts:** While the use of `UserDefaults` is effective, consider creating a dedicated service or repository class within `ShortlessKit` to manage access. This would formalize the "contract" of keys and data types, making it more explicit and type-safe, rather than relying on raw string keys in each extension.
2.  **Document `ShortlessKit` API:** Add comprehensive inline documentation to the public-facing types and methods in `ShortlessKit`. Since it is the core dependency for all other targets, clear documentation here would provide the highest leverage for future development.
