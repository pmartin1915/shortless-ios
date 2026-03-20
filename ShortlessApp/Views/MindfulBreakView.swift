import SwiftUI

/// Presented when the user taps "I feel like scrolling" — shows a random
/// healthy alternative activity with an optional countdown timer.
struct MindfulBreakView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activity: Activity
    @State private var timerRemaining: Int = 0
    @State private var timerActive = false
    @State private var timer: Timer?

    init() {
        _activity = State(initialValue: Activity.random())
    }

    var body: some View {
        ZStack {
            ShortlessTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: activity.icon)
                    .font(.system(size: 48))
                    .foregroundColor(ShortlessTheme.accent)

                Text(activity.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(activity.description)
                    .font(.system(size: ShortlessTheme.bodySize))
                    .foregroundColor(ShortlessTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if activity.durationSeconds > 0 {
                    timerView
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        withAnimation {
                            activity = Activity.random(excluding: activity)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 14))
                            Text("Try Something Else")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(ShortlessTheme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ShortlessTheme.cardFill)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ShortlessTheme.accent, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }

                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Text("I'm Good Now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(ShortlessTheme.accent)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, ShortlessTheme.containerPadding)
                .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .onDisappear { stopTimer() }
    }

    // MARK: - Timer

    private var timerView: some View {
        VStack(spacing: 12) {
            if timerActive {
                Text(timerFormatted)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(timerRemaining > 0 ? ShortlessTheme.accent : .green)
                    .contentTransition(.numericText())

                if timerRemaining == 0 {
                    Text("Well done!")
                        .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                        .foregroundColor(.green)
                }
            } else {
                Button {
                    startTimer()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.system(size: 14))
                        Text("Start \(activity.durationSeconds / 60)-Minute Timer")
                            .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                    }
                    .foregroundColor(ShortlessTheme.accent)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(ShortlessTheme.cardFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
                    )
                    .cornerRadius(8)
                }
            }
        }
    }

    private var timerFormatted: String {
        let m = timerRemaining / 60
        let s = timerRemaining % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        timerRemaining = activity.durationSeconds
        timerActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerRemaining > 0 {
                timerRemaining -= 1
            } else {
                stopTimer()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Activity Model

struct Activity: Equatable {
    let title: String
    let description: String
    let icon: String
    let durationSeconds: Int // 0 = no timer

    static let all: [Activity] = [
        Activity(
            title: "Take 10 Deep Breaths",
            description: "Breathe in for 4 seconds, hold for 4, out for 4. Reset your nervous system.",
            icon: "wind",
            durationSeconds: 120
        ),
        Activity(
            title: "Step Outside",
            description: "Walk around the block or just stand in the fresh air for a few minutes.",
            icon: "figure.walk",
            durationSeconds: 300
        ),
        Activity(
            title: "Stretch It Out",
            description: "Stand up and stretch your arms, neck, and back. Your body will thank you.",
            icon: "figure.cooldown",
            durationSeconds: 180
        ),
        Activity(
            title: "Message Someone",
            description: "Text a friend or family member you haven't talked to in a while. Real connection beats the feed.",
            icon: "message.fill",
            durationSeconds: 0
        ),
        Activity(
            title: "Drink Some Water",
            description: "Get up, fill a glass, and drink it slowly. Simple, effective, and you probably need it.",
            icon: "drop.fill",
            durationSeconds: 0
        ),
        Activity(
            title: "Write One Thought",
            description: "Open Notes and write down one thing on your mind. It doesn't have to be profound.",
            icon: "pencil.line",
            durationSeconds: 0
        ),
        Activity(
            title: "Look Out a Window",
            description: "Spend a minute watching the world outside. Notice something you haven't before.",
            icon: "window.casement",
            durationSeconds: 60
        ),
        Activity(
            title: "Tidy One Thing",
            description: "Pick up one item that's out of place. Small wins compound.",
            icon: "sparkles",
            durationSeconds: 0
        ),
        Activity(
            title: "Listen to a Song",
            description: "Put on a favorite song and actually listen to it — no multitasking.",
            icon: "music.note",
            durationSeconds: 240
        ),
        Activity(
            title: "Close Your Eyes",
            description: "Just sit with your eyes closed for a minute. Let your mind rest.",
            icon: "moon.fill",
            durationSeconds: 60
        )
    ]

    static func random() -> Activity {
        all.randomElement() ?? all[0]
    }

    static func random(excluding current: Activity) -> Activity {
        let filtered = all.filter { $0 != current }
        return filtered.randomElement() ?? all[0]
    }
}
