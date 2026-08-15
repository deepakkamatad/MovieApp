//
//  TrailerView.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import SwiftUI
import WebKit

struct TrailerView: UIViewRepresentable {

    let videoKey: String
    /// True until the player reports it's ready (or gives up).
    @Binding var isLoading: Bool
    @Binding var didFail: Bool

    private static let origin = "https://www.youtube.com"
    fileprivate static let eventHandlerName = "trailerEvent"

    func makeCoordinator() -> Coordinator {
        Coordinator(isLoading: $isLoading, didFail: $didFail)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        // The player reports readiness and embed restrictions through the
        // IFrame API rather than through navigation callbacks.
        configuration.userContentController.add(
            context.coordinator,
            name: Self.eventHandlerName
        )

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedKey != videoKey else { return }
        context.coordinator.loadedKey = videoKey

        // Loading the embed URL directly - or via `loadHTMLString`, which
        // produces an opaque origin - makes YouTube reject the player with
        // "Error 153". `loadSimulatedRequest` gives the document a real
        // youtube.com origin, matching the `origin` the player validates.
        guard let url = URL(string: "\(Self.origin)/embed/\(videoKey)") else {
            DispatchQueue.main.async {
                isLoading = false
                didFail = true
            }
            return
        }

        // Avoid mutating state during the SwiftUI update pass.
        DispatchQueue.main.async { isLoading = true }

        webView.loadSimulatedRequest(
            URLRequest(url: url),
            responseHTML: Self.embedHTML(for: videoKey)
        )
    }

    static func dismantleUIView(_ webView: WKWebView, coordinator: Coordinator) {
        webView.configuration.userContentController
            .removeScriptMessageHandler(forName: eventHandlerName)
    }

    private static func embedHTML(for videoKey: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
        <style>
            * { margin: 0; padding: 0; }
            html, body { width: 100%; height: 100%; background-color: #000; overflow: hidden; }
            #player { width: 100%; height: 100%; }
        </style>
        </head>
        <body>
        <div id="player"></div>
        <script src="https://www.youtube.com/iframe_api"></script>
        <script>
            function post(event) {
                window.webkit.messageHandlers.\(eventHandlerName).postMessage(event);
            }

            // If the API script itself is blocked, stop the spinner and fall
            // back to the "watch on YouTube" link.
            var apiTimeout = setTimeout(function () { post('failed'); }, 8000);

            function onYouTubeIframeAPIReady() {
                clearTimeout(apiTimeout);
                new YT.Player('player', {
                    videoId: '\(videoKey)',
                    host: '\(origin)',
                    playerVars: {
                        playsinline: 1,
                        rel: 0,
                        modestbranding: 1,
                        origin: '\(origin)'
                    },
                    events: {
                        onReady: function () { post('ready'); },
                        onError: function () { post('failed'); }
                    }
                });
            }
        </script>
        </body>
        </html>
        """
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var loadedKey: String?
        private let isLoading: Binding<Bool>
        private let didFail: Binding<Bool>

        init(isLoading: Binding<Bool>, didFail: Binding<Bool>) {
            self.isLoading = isLoading
            self.didFail = didFail
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == TrailerView.eventHandlerName else { return }

            // Either outcome ends the loading state.
            isLoading.wrappedValue = false
            if message.body as? String == "failed" {
                didFail.wrappedValue = true
            }
        }

        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            fail()
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            fail()
        }

        private func fail() {
            isLoading.wrappedValue = false
            didFail.wrappedValue = true
        }
    }
}
