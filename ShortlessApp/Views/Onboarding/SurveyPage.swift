import SwiftUI

/// Onboarding page 2: "How much time do you spend on short-form video?"
struct SurveyPage: View {
    @Binding var selectedMinutes: Int
    let onNext: () -> Void

    private let options: [(label: String, minutes: Int)] = [
        ("Less than 30 min", 15),
        ("30 - 60 min", 45),
        ("1 - 2 hours", 90),
        ("2+ hours", 150)
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 44))
                    .foregroundColor(ShortlessTheme.accent)

                Text("How much time do you\nspend on short-form video?")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(ShortlessTheme.textPrimary)
                    .multilineTextAlignment(.center)

                VStack(spacing: 10) {
                    ForEach(options, id: \.minutes) { option in
                        Button(action: { selectedMinutes = option.minutes }) {
                            HStack {
                                Text(option.label)
                                    .font(.system(size: ShortlessTheme.bodySize, weight: .medium))
                                    .foregroundColor(selectedMinutes == option.minutes ? .white : ShortlessTheme.textSecondary)
                                Spacer()
                                if selectedMinutes == option.minutes {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(selectedMinutes == option.minutes ? ShortlessTheme.accent : ShortlessTheme.cardFill)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedMinutes == option.minutes ? ShortlessTheme.accent : ShortlessTheme.cardBorder, lineWidth: 1)
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
