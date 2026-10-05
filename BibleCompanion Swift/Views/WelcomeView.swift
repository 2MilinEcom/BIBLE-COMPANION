import SwiftUI

struct WelcomeView: View {

    // =====================================================
    // MARK: - Body
    // =====================================================

    var body: some View {

        VStack(
            spacing:
                28
        ) {

            Spacer()


            // =================================================
            // MARK: Companion
            // =================================================

            ZStack {

                Circle()
                    .fill(
                        Color
                            .accentColor
                            .opacity(
                                0.08
                            )
                    )
                    .frame(
                        width:
                            220,
                        height:
                            220
                    )


                CompanionAvatar(
                    size: 190,
                    behavior: .floating
                )
            }



            // =================================================
            // MARK: Copy
            // =================================================

            VStack(
                spacing:
                    12
            ) {

                Text(
                    "Meet Your Bible Companion"
                )
                .font(
                    .largeTitle
                )
                .bold()
                .multilineTextAlignment(
                    .center
                )


                Text(
                    """
                    This isn't just a Bible explainer.

                    Your Companion will learn where you are, what you're exploring, and how you like to be challenged.
                    """
                )
                .font(
                    .title3
                )
                .foregroundStyle(
                    .secondary
                )
                .multilineTextAlignment(
                    .center
                )
            }


            Spacer()


            // =================================================
            // MARK: Continue
            // =================================================

            NavigationLink {

                SpiritualCheckInView()

            } label: {

                Text(
                    "Get Started"
                )
                .fontWeight(
                    .semibold
                )
                .frame(
                    maxWidth:
                        .infinity
                )
                .padding(
                    .vertical,
                    16
                )
            }
            .buttonStyle(
                .borderedProminent
            )
        }
        .padding(
            24
        )
    }
}


#Preview {

    NavigationStack {

        WelcomeView()
            .environmentObject(
                OnboardingViewModel()
            )
    }
}
