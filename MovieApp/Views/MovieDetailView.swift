//
//  MovieDetailView.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import SwiftUI

struct MovieDetailView: View {

    @StateObject private var viewModel: MovieDetailViewModel
    @Environment(\.openURL) private var openURL

    @State private var trailerFailed = false
    @State private var trailerLoading = true

    init(movieID: Int) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieID: movieID))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(message: "Loading details…")
            } else if let message = viewModel.errorMessage {
                ErrorView(message: message) {
                    Task { await viewModel.load() }
                }
            } else if let details = viewModel.details {
                detailContent(details)
            } else {
                EmptyStateView(title: "No details available", systemImage: "film")
            }
        }
        .navigationTitle(viewModel.details?.title ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if viewModel.details == nil { await viewModel.load() }
        }
    }

    private func detailContent(_ details: MovieDetails) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                trailerSection
                headerSection(details)
                metaSection(details)

                if !details.genresText.isEmpty {
                    Text(details.genresText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                section(title: "Plot") {
                    Text(details.overview.isEmpty ? "No overview available." : details.overview)
                        .font(.body)
                }

                if !viewModel.cast.isEmpty {
                    castSection
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var trailerSection: some View {
        if let trailer = viewModel.trailer {
            if trailerFailed {
                blockedTrailer(trailer)
            } else {
                VStack(spacing: 8) {
                    TrailerView(
                        videoKey: trailer.key,
                        isLoading: $trailerLoading,
                        didFail: $trailerFailed
                    )
                    .frame(height: 210)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        if trailerLoading {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black)
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            }
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: trailerLoading)

                    if let url = trailer.youtubeURL {
                        Button {
                            openURL(url)
                        } label: {
                            Label("Watch on YouTube", systemImage: "play.circle")
                        }
                        .font(.subheadline)
                    }
                }
            }
        } else {
            placeholderBox {
                Text("Trailer unavailable")
                    .foregroundColor(.secondary)
            }
        }
    }

    private func blockedTrailer(_ trailer: Video) -> some View {
        placeholderBox {
            VStack(spacing: 12) {
                Image(systemName: "play.slash")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)

                Text("This trailer can't be played here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                if let url = trailer.youtubeURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Watch on YouTube", systemImage: "play.circle")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }

    private func placeholderBox<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
            content()
        }
        .frame(height: 210)
    }


    private func headerSection(_ details: MovieDetails) -> some View {
        HStack(alignment: .top) {
            Text(details.title)
                .font(.title2.bold())
            Spacer()
            FavoriteButton(movieID: details.id)
                .font(.title2)
        }
    }

    private func metaSection(_ details: MovieDetails) -> some View {
        HStack(spacing: 16) {
            Label(String(format: "%.1f", details.voteAverage), systemImage: "star.fill")
                .foregroundColor(.orange)
            Label(details.runtimeText, systemImage: "clock")
                .foregroundColor(.secondary)
        }
        .font(.subheadline)
    }

    private var castSection: some View {
        section(title: "Cast") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.cast.prefix(10)) { member in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(.subheadline.weight(.semibold))
                        if let character = member.character, !character.isEmpty {
                            Text(character)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func section<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Divider()
            content()
        }
    }
}

