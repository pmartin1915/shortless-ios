import SwiftUI

/// Onboarding page 4: Reduction goal selector.
struct GoalPage: View {
    @Binding var selectedGoal: Int
    let onNext: () -> Void

    private let goals: [(label: String, percent: Int, description: String)] = [
        ("Cut by 25%", 25, "A gentle start — remove the worst triggers"),
        ("Cut by 50%", 50, "Balanced approach — half the scroll, double the focus"),
        ("Cut by 75%", 75, "Serious commitment — keep only what matters"),
        ("Block it all", 100, "Full digital detox — remove all short-form feeds")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "target")
                    .font(.system(size: 44))
                    .foregroundColor(ShortlessTheme.accent)

                Text("Set your goal")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)

                Text("How much do you want to reduce?")
                    .font(.system(size: ShortlessTheme.bodySize))
                    .foregroundColor(ShortlessTheme.textTertiary)

                VStack(spacing: 10) {
                    ForEach(goals, id: \.percent) { goal in
                        Button(action: { selectedGoal = goal.percent }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(goal.label)
                                        .font(.system(size: ShortlessTheme.bodySize, weight: .semibold))
                                        .foregroundColor(selectedGoal == goal.percent ? .white : ShortlessTheme.textPrimary)
                                    Text(goal.description)
                                        .font(.system(size: 11))
                                        .foregroundColor(selectedGoal == goal.percent ? .white.opacity(0.8) : ShortlessTheme.textTertiary)
                                }
                                Spacer()
                                if selectedGoal == goal.percent {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(selectedGoal == goal.percent ? ShortlessTheme.accent : ShortlessTheme.cardFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedGoal == goal.percent ? ShortlessTheme.accent : ShortlessTheme.cardBorder, lineWidth: 1)
                            )
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, ShortlessTheme.containerPadding)
            }

            Spacer()

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(ShortlessTheme.accent)
                    .cornerRadius(10)
            }
            .padding(.horizontal, ShortlessTheme.containerPadding)
            .padding(.bottom, 48)
        }
    }
}
