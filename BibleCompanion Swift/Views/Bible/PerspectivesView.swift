import SwiftUI

struct PerspectivesView: View {

    let passage: String

    @EnvironmentObject
    var onboardingViewModel: OnboardingViewModel

    @StateObject
    private var viewModel =
        PerspectivesViewModel()


    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // MARK: Passage

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text("PASSAGE")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(passage)
                        .font(.subheadline)
                        .lineLimit(5)
                }


                Divider()


                // MARK: Loading

                if viewModel.isLoading {

                    HStack(spacing: 12) {

                        ProgressView()

                        Text(
                            "Comparing interpretations..."
                        )
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 40)


                // MARK: Response

                } else if let response =
                            viewModel.response {

                    VStack(
                        alignment: .leading,
                        spacing: 10
                    ) {

                        Text("What the passage says")
                            .font(.title2)
                            .bold()

                        Text(response.passageSummary)
                            .foregroundStyle(.secondary)
                    }


                    if !response
                        .areasOfAgreement
                        .isEmpty {

                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Text("Common Ground")
                                .font(.title2)
                                .bold()


                            ForEach(
                                response.areasOfAgreement,
                                id: \.self
                            ) { agreement in

                                HStack(
                                    alignment: .top,
                                    spacing: 10
                                ) {

                                    Image(
                                        systemName:
                                            "checkmark.circle"
                                    )
                                    .foregroundStyle(
                                        .secondary
                                    )

                                    Text(agreement)
                                }
                            }
                        }
                    }


                    Divider()


                    Text("Major Perspectives")
                        .font(.title2)
                        .bold()


                    ForEach(
                        response.perspectives
                    ) { perspective in

                        PerspectiveCard(
                            perspective: perspective,
                            passage: passage
                        )
                    }


                // MARK: Error

                } else if let error =
                            viewModel.errorMessage {

                    VStack(
                        alignment: .leading,
                        spacing: 14
                    ) {

                        Text(
                            "Perspectives couldn't load."
                        )
                        .font(.headline)

                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Button("Try Again") {

                            Task {

                                await viewModel.retry(
                                    passage: passage,
                                    profile:
                                        onboardingViewModel.profile
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Perspectives")
        .navigationBarTitleDisplayMode(.inline)
        .task {

            await viewModel.load(
                passage: passage,
                profile:
                    onboardingViewModel.profile
            )
        }
    }
}


// MARK: - Perspective Card

struct PerspectiveCard: View {

    let perspective: Perspective
    let passage: String

    @State
    private var isExpanded = false


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 16
        ) {

            VStack(
                alignment: .leading,
                spacing: 6
            ) {

                Text(perspective.name)
                    .font(.title3)
                    .bold()

                Text(perspective.summary)
                    .foregroundStyle(.secondary)
            }


            Button {

                withAnimation {
                    isExpanded.toggle()
                }

            } label: {

                HStack {

                    Text(
                        isExpanded
                        ? "Hide Details"
                        : "Examine This View"
                    )
                    .fontWeight(.semibold)

                    Spacer()

                    Image(
                        systemName:
                            isExpanded
                            ? "chevron.up"
                            : "chevron.down"
                    )
                }
            }
            .buttonStyle(.plain)


            if isExpanded {

                Divider()


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("Core Argument")
                        .font(.headline)

                    Text(
                        perspective.coreArgument
                    )
                }


                if !perspective
                    .supportingPassages
                    .isEmpty {

                    VStack(
                        alignment: .leading,
                        spacing: 8
                    ) {

                        Text("Supporting Passages")
                            .font(.headline)


                        ForEach(
                            perspective
                                .supportingPassages,
                            id: \.self
                        ) { reference in

                            Label(
                                reference,
                                systemImage:
                                    "book.closed"
                            )
                            .font(.subheadline)
                        }
                    }
                }


                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("Strongest Objection")
                        .font(.headline)

                    Text(
                        perspective
                            .strongestObjection
                    )
                }


                NavigationLink {

                    CompanionView(
                        passage: passage,
                        mode: .challenge,
                        initialPrompt:
                            """
                            Challenge the \(perspective.name) interpretation of this passage.

                            Its strongest argument is:

                            \(perspective.coreArgument)

                            Begin by helping me test this interpretation against the biblical text.
                            """
                    )

                } label: {

                    HStack {

                        Image(
                            systemName:
                                "brain.head.profile"
                        )

                        Text(
                            "Challenge This View"
                        )
                        .fontWeight(.semibold)

                        Spacer()

                        Image(
                            systemName:
                                "chevron.right"
                        )
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity
                    )
                }
                .buttonStyle(
                    .borderedProminent
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(
                cornerRadius: 20
            )
            .fill(
                Color(
                    .secondarySystemBackground
                )
            )
        )
    }
}


#Preview {

    NavigationStack {

        PerspectivesView(
            passage:
                """
                1 Peter 3:21

                Baptism, which corresponds to this, now saves you...
                """
        )
        .environmentObject(
            OnboardingViewModel()
        )
    }
}
