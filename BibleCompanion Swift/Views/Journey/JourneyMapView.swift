import SwiftUI

struct JourneyMapView: View {

    let journey: JourneyPath

    @StateObject
    private var progressStore =
        JourneyProgressStore.shared

    private let rowHeight: CGFloat = 145


    init(
        journey: JourneyPath =
            JourneyLibrary.meetJesus
    ) {
        self.journey = journey
    }


    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // MARK: - Header

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text(
                        journey.category
                            .rawValue
                            .uppercased()
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)


                    Text(journey.title)
                        .font(.largeTitle)
                        .bold()


                    Text(journey.subtitle)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }


                // MARK: - Progress

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    HStack {

                        Text(
                            "\(progressStore.completedCount(in: journey)) of \(journey.checkpoints.count) checkpoints"
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)


                        Spacer()


                        Text(
                            "\(Int(progressStore.progress(in: journey) * 100))%"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }


                    ProgressView(
                        value:
                            progressStore.progress(
                                in: journey
                            )
                    )
                    .tint(.accentColor)
                }


                // MARK: - Journey Path

                VStack(
                    spacing: 0
                ) {

                    ForEach(
                        Array(
                            journey
                                .checkpoints
                                .enumerated()
                        ),
                        id: \.element.id
                    ) { index, checkpoint in

                        checkpointRow(
                            checkpoint,
                            index: index
                        )
                    }
                }
                .background {

                    // One continuous line behind every checkpoint.

                    GeometryReader { geometry in

                        let totalHeight =
                            geometry.size.height

                        let lineHeight =
                            max(
                                0,
                                totalHeight - rowHeight
                            )

                        Rectangle()
                            .fill(
                                Color.secondary
                                    .opacity(0.22)
                            )
                            .frame(
                                width: 3,
                                height: lineHeight
                            )
                            .position(
                                x:
                                    geometry.size.width / 2,
                                y:
                                    geometry.size.height / 2
                            )
                    }
                }


                // MARK: - Complete State

                if progressStore.completedCount(
                    in: journey
                ) == journey.checkpoints.count {

                    VStack(
                        spacing: 10
                    ) {

                        Image(
                            systemName:
                                "checkmark.seal.fill"
                        )
                        .font(.largeTitle)
                        .foregroundStyle(
                            Color.accentColor
                        )


                        Text(
                            "Journey Complete"
                        )
                        .font(.title2)
                        .bold()


                        Text(
                            "You've completed the \(journey.title) journey."
                        )
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(
                            .center
                        )
                    }
                    .frame(
                        maxWidth: .infinity
                    )
                    .padding(24)
                }
            }
            .padding()
        }
        .navigationTitle("Journey")
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // MARK: - Row

    @ViewBuilder
    private func checkpointRow(
        _ checkpoint: JourneyCheckpoint,
        index: Int
    ) -> some View {

        let completed =
            progressStore.isCompleted(
                checkpoint,
                in: journey
            )

        let current =
            progressStore.isCurrent(
                checkpoint,
                in: journey
            )

        let available =
            progressStore.isAvailable(
                checkpoint,
                in: journey
            )

        let cardOnLeft =
            index.isMultiple(of: 2)


        HStack(
            alignment: .center,
            spacing: 10
        ) {

            // MARK: Left Column

            Group {

                if cardOnLeft {

                    checkpointDestination(
                        checkpoint,
                        completed: completed,
                        current: current,
                        available: available
                    )

                } else {

                    Color.clear
                        .frame(
                            height: 1
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .trailing
            )


            // MARK: Center Node

            pathNode(
                checkpoint,
                completed: completed,
                current: current
            )
            .frame(
                width: 50
            )


            // MARK: Right Column

            Group {

                if !cardOnLeft {

                    checkpointDestination(
                        checkpoint,
                        completed: completed,
                        current: current,
                        available: available
                    )

                } else {

                    Color.clear
                        .frame(
                            height: 1
                        )
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
        .frame(
            height: rowHeight
        )
    }


    // MARK: - Navigation

    @ViewBuilder
    private func checkpointDestination(
        _ checkpoint: JourneyCheckpoint,
        completed: Bool,
        current: Bool,
        available: Bool
    ) -> some View {

        if available {

            NavigationLink {

                JourneyCheckpointView(
                    journey: journey,
                    checkpoint: checkpoint,
                    onComplete: {

                        progressStore.complete(
                            checkpoint,
                            in: journey
                        )
                    }
                )

            } label: {

                JourneyCheckpointCard(
                    checkpoint: checkpoint,
                    completed: completed,
                    current: current
                )
            }
            .buttonStyle(.plain)

        } else {

            JourneyCheckpointCard(
                checkpoint: checkpoint,
                completed: false,
                current: false
            )
            .opacity(0.55)
        }
    }


    // MARK: - Node

    private func pathNode(
        _ checkpoint: JourneyCheckpoint,
        completed: Bool,
        current: Bool
    ) -> some View {

        ZStack {

            // Hides the line behind the circle.

            Circle()
                .fill(
                    Color(
                        .systemBackground
                    )
                )
                .frame(
                    width: 54,
                    height: 54
                )


            Circle()
                .fill(
                    completed
                    ? Color.accentColor
                    : current
                    ? Color.accentColor
                        .opacity(0.15)
                    : Color(
                        .secondarySystemBackground
                    )
                )
                .frame(
                    width: 46,
                    height: 46
                )


            Circle()
                .stroke(
                    current
                    ? Color.accentColor
                    : Color.secondary
                        .opacity(0.35),
                    lineWidth:
                        current ? 3 : 1
                )
                .frame(
                    width: 46,
                    height: 46
                )


            if completed {

                Image(
                    systemName:
                        "checkmark"
                )
                .fontWeight(.bold)
                .foregroundStyle(
                    .white
                )

            } else {

                Text(
                    "\(checkpoint.order)"
                )
                .fontWeight(.bold)
            }
        }
    }
}


// MARK: - Card

private struct JourneyCheckpointCard:
    View {

    let checkpoint: JourneyCheckpoint

    let completed: Bool
    let current: Bool


    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 7
        ) {

            HStack {

                if completed {

                    Text("COMPLETED")

                } else if current {

                    Text("CURRENT")

                } else {

                    Text("UPCOMING")
                }


                Spacer()


                if !completed &&
                    !current {

                    Image(
                        systemName:
                            "lock.fill"
                    )
                }
            }
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(.secondary)


            Text(
                checkpoint.title
            )
            .font(.headline)


            Text(
                checkpoint.passage
            )
            .font(.caption)
            .foregroundStyle(
                .secondary
            )
        }
        .padding(14)
        .frame(
            maxWidth: 145,
            alignment: .leading
        )
        .background(
            RoundedRectangle(
                cornerRadius: 16
            )
            .fill(
                current
                ? Color.accentColor
                    .opacity(0.10)
                : Color(
                    .secondarySystemBackground
                )
            )
        )
    }
}


#Preview {

    NavigationStack {

        JourneyMapView()
            .environmentObject(
                OnboardingViewModel()
            )
    }
}
