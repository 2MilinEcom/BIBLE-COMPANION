import SwiftUI

@MainActor
struct ContentView: View {

  @ObservedObject
  private var appSettings = AppSettingsStore.shared

  @AppStorage("onboardingComplete")
  private var onboardingComplete = false

  @StateObject
  private var onboardingViewModel =
    OnboardingViewModel()

  @StateObject
  private var appTutorial =
    AppTutorialCoordinator()

  @StateObject
  private var companionGrowth =
    CompanionGrowthStore.shared

  var body: some View {

    ZStack {

      if onboardingComplete {

        NavigationStack {
          HomeView()
        }
        .transition(
          .opacity
        )

      } else {

        NavigationStack {
          WelcomeView()
        }
        .transition(
          .opacity
        )
      }
    }
    .animation(
      .easeInOut(
        duration: 0.55
      ),
      value:
        onboardingComplete
    )
    .environmentObject(
      onboardingViewModel
    )
    .environmentObject(
      appTutorial
    )
    .overlay {

      if onboardingComplete,
        !appTutorial.isActive,
        let stage =
          companionGrowth
          .pendingStageReveal
      {

        CompanionGrowthRevealView(
          stage:
            stage,
          onContinue: {

            companionGrowth
              .acknowledgePendingStageReveal()
          }
        )
        .transition(
          .opacity
        )
        .zIndex(1000)
      }
    }
    .animation(
      .easeInOut(
        duration: 0.30
      ),
      value:
        companionGrowth
        .pendingStageReveal
    )
    .preferredColorScheme(appSettings.appearance.preferredColorScheme)
    .onAppear {

      companionGrowth
        .refresh()
    }
  }
}

#Preview {
  ContentView()
}
