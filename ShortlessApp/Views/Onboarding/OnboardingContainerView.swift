import SwiftUI
import ShortlessKit

/// Multi-page onboarding flow: Welcome → Survey → Impact → Goal → Safari Setup.
struct OnboardingContainerView: View {
    @ObservedObject var settings: SettingsStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var selectedMinutes: Int = 60
    @State private var selectedGoal: Int = 100

    private let pageCount = 5

    var body: some View {
        ZStack {
            ShortlessTheme.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                WelcomePage(onNext: nextPage)
                    .tag(0)

                SurveyPage(selectedMinutes: $selectedMinutes, onNext: {
                    settings.setDailyShortMinutes(selectedMinutes)
                    nextPage()
                })
                .tag(1)

                ImpactPage(dailyMinutes: selectedMinutes, onNext: nextPage)
                    .tag(2)

                GoalPage(selectedGoal: $selectedGoal, onNext: {
                    settings.setReductionGoalPercent(selectedGoal)
                    nextPage()
                })
                .tag(3)

                SetupPage(onDone: { dismiss() })
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Page indicator
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<pageCount, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? ShortlessTheme.accent : ShortlessTheme.textTertiary.opacity(0.4))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Skip") { dismiss() }
                    .foregroundColor(ShortlessTheme.accent)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func nextPage() {
        if currentPage < pageCount - 1 {
            currentPage += 1
        }
    }
}
