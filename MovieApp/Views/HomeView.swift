//
//  HomeView.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("Movies")
                .searchable(
                    text: $viewModel.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search movies"
                )
                .onSearchTextChange(of: viewModel.searchText) { newValue in
                    viewModel.onSearchTextChanged(newValue)
                }
                .task {
                    if case .idle = viewModel.state {
                        await viewModel.loadPopular()
                    }
                }
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .loaded(let movies):
            movieList(movies)
        case .empty:
            EmptyStateView(title: emptyStateTitle, systemImage: emptyStateIcon)
        case .error(let message):
            ErrorView(message: message) {
                Task { await viewModel.retry() }
            }
        }
    }
    
    private var emptyStateTitle: String {
        let query = viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? "No movies found" : "No results for \u{201C}\(query)\u{201D}"
    }

    private var emptyStateIcon: String {
        viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "film"
            : "magnifyingglass"
    }

    private func movieList(_ movies: [Movie]) -> some View {
        List {
            ForEach(movies) { movie in
                ZStack {
                    MovieRowView(movie: movie)
                    NavigationLink(destination: MovieDetailView(movieID: movie.id)) {
                        EmptyView()
                    }
                    .opacity(0)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .onAppear {
                    viewModel.loadNextPageIfNeeded(currentItem: movie)
                }
            }

            paginationFooter
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var paginationFooter: some View {
        Group {
            if let message = viewModel.nextPageError {
                VStack(spacing: 8) {
                    Text(message)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        viewModel.loadNextPage()
                    }
                    .font(.subheadline)
                }
            } else if viewModel.isLoadingNextPage {
                ProgressView()
                    .padding(.vertical, 4)
            } else if !viewModel.canLoadMore {
                Text("You've reached the end")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .listRowSeparator(.hidden)
    }
}

private extension View {
    @ViewBuilder
    func onSearchTextChange<Value: Equatable>(
        of value: Value,
        perform action: @escaping (Value) -> Void
    ) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in action(newValue) }
        } else {
            self.onChange(of: value) { newValue in action(newValue) }
        }
    }
}
