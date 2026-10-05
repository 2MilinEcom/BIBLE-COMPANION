import SwiftUI

struct BibleSearchView: View {

    @StateObject
    private var viewModel = BibleViewModel()


    var body: some View {

        VStack(spacing: 0) {

            // MARK: - Search

            TextField(
                "Search John 3, baptism, faith...",
                text: $viewModel.searchText
            )
            .textFieldStyle(.roundedBorder)
            .padding()


            if let error = viewModel.errorMessage {

                ContentUnavailableView(
                    "Bible Couldn't Load",
                    systemImage:
                        "exclamationmark.triangle",
                    description:
                        Text(error)
                )

            } else if !viewModel.searchText.isEmpty {

                searchResults

            } else {

                bibleLibrary
            }
        }
        .navigationTitle("Bible")
        .navigationBarTitleDisplayMode(
            .inline
        )
    }


    // MARK: - Bible Library

    private var bibleLibrary: some View {

        List {

            Section(
                "Old Testament"
            ) {

                ForEach(
                    viewModel.oldTestamentBooks
                ) { book in

                    NavigationLink {

                        ChapterPickerView(
                            book: book
                        )

                    } label: {

                        BibleBookRow(
                            book: book
                        )
                    }
                }
            }


            Section(
                "New Testament"
            ) {

                ForEach(
                    viewModel.newTestamentBooks
                ) { book in

                    NavigationLink {

                        ChapterPickerView(
                            book: book
                        )

                    } label: {

                        BibleBookRow(
                            book: book
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }


    // MARK: - Search Results

    private var searchResults: some View {

        Group {

            if viewModel.searchResults.isEmpty {

                ContentUnavailableView(
                    "No Results",
                    systemImage:
                        "magnifyingglass",
                    description:
                        Text(
                            "Try another passage or keyword."
                        )
                )

            } else {

                List(
                    viewModel.searchResults
                ) { verse in

                    NavigationLink {

                        BibleReaderView(
                            book: verse.book,
                            chapter: verse.chapter,
                            initialVerses: [verse.verse]
                        )

                    } label: {

                        VStack(
                            alignment: .leading,
                            spacing: 6
                        ) {

                            Text(
                                verse.reference
                            )
                            .font(.headline)


                            Text(
                                verse.text
                            )
                            .font(.subheadline)
                            .foregroundStyle(
                                .secondary
                            )
                            .lineLimit(3)
                        }
                        .padding(
                            .vertical,
                            4
                        )
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}


// MARK: - Book Row

struct BibleBookRow: View {

    let book: BibleBook


    var body: some View {

        HStack {

            Image(
                systemName:
                    "book.closed"
            )
            .foregroundStyle(
                .secondary
            )


            Text(book.name)


            Spacer()
        }
        .padding(
            .vertical,
            3
        )
    }
}


#Preview {

    NavigationStack {
        BibleSearchView()
    }
}
