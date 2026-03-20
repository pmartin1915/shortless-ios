import SwiftUI

/// Onboarding page 3: Personalized impact calculation.
struct ImpactPage: View {
    let dailyMinutes: Int
    let onNext: () -> Void

    private var weeklyHours: Double { Double(dailyMinutes) * 7.0 / 60.0 }
    private var yearlyDays: Double { Double(dailyMinutes) * 365.0 / 60.0 / 24.0 }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.orange)

                Text("That adds up fast.")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)

                VStack(spacing: 16) {
                    impactRow(
                        value: String(format: "%.1f hours", weeklyHours),
                        label: "per week on short-form video"
                    )
                    impactRow(
                        value: String(format: "%.0f days", yearlyDays),
                        label: "per year spent scrolling"
                    )
                }
                .padding(.horizontal, ShortlessTheme.containerPadding)

                Text("Short-form feeds are built to keep you watching. Without realizing it, quick clips add up to hours of time you could spend on things that matter to you.")
                    .font(.system(size: ShortlessTheme.bodySize))
                    .foregroundColor(ShortlessTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text("You deserve the choice.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ShortlessTheme.accent)
            }

            Spacer()

            Button(action: onNext) {
                Text("Take Back My Time")
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

    private func impactRow(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(ShortlessTheme.textPrimary)

            Text(label)
                .font(.system(size: ShortlessTheme.bodySize))
                .foregroundColor(ShortlessTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(ShortlessTheme.cardFill)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(ShortlessTheme.cardBorder, lineWidth: 1)
        )
        .cornerRadius(10)
    }
}
