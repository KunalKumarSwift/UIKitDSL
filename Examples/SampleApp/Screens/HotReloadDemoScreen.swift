import UIKit
import UIKitDSL

// MARK: - HotReloadDemoScreen
//
// HOW TO TRIGGER HOT RELOAD:
// 1. Add the Inject package to this app target (see docs/06-hot-reload.md).
// 2. Set DYLD_INSERT_LIBRARIES=$(INJECT_DYLIB_PATH) in the scheme's environment.
// 3. Call `_ = HotReloadHost.shared` in AppDelegate.application(_:didFinishLaunchingWithOptions:).
// 4. Run on the Simulator, edit any Swift file, and save — the screen rebuilds instantly.
//
// State preservation:
// - The text you type in the name field survives reloads (stored in HotReloadDemoViewModel).
// - The tap count survives reloads for the same reason.
// - The scroll position is preserved because UIScrollView.contentOffset is not touched by update().

final class HotReloadDemoScreen: DSLViewController<HotReloadDemoViewModel> {

    init(viewModel: HotReloadDemoViewModel) {
        super.init(viewModel: viewModel) { state in
            scroll {
                vstack(spacing: 20) {

                    // MARK: Explainer label
                    vstack(spacing: 8) {
                        label("Hot Reload Demo")
                            .font(.title1)

                        label("Edit this file in Xcode and save — changes appear instantly without relaunch. Your name and tap count below are preserved across reloads because they live in the view model, not in the views.")
                            .font(.subheadline)
                            .tintColor(.secondaryLabel)
                    }
                    .padding(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))

                    // MARK: Name text field
                    vstack(spacing: 6, alignment: .leading) {
                        label("Your name")
                            .font(.caption1)
                            .tintColor(.secondaryLabel)

                        textField("Enter your name…", text: state.name) { newValue in
                            viewModel.mutate { $0.name = newValue }
                        }
                        .frame(height: 44)
                        .background(.secondarySystemBackground)
                        .cornerRadius(10)
                        .padding(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
                    }

                    // MARK: Greeting (updates live as you type)
                    if !state.name.isEmpty {
                        label("Hello, \(state.name)!")
                            .font(.title3)
                            .tintColor(.systemBlue)
                            .id("greeting-label")
                    }

                    // MARK: Counter button
                    vstack(spacing: 8) {
                        label("Tap count: \(state.tapCount)")
                            .font(.headline)

                        button("Tap me") {
                            viewModel.incrementTapCount()
                        }
                        .frame(height: 44)
                        .background(.systemGreen)
                        .cornerRadius(10)
                        .tintColor(.white)
                    }

                    // MARK: Scrollable content (offset survives reloads)
                    vstack(spacing: 12) {
                        label("Scrollable content below")
                            .font(.headline)

                        label("Scroll down, then trigger a hot reload. The scroll position is preserved.")
                            .font(.body)
                            .tintColor(.secondaryLabel)

                        ForEach(1...20, id: \.self) { index in
                            hstack(spacing: 12) {
                                label("\(index)")
                                    .font(.headline)
                                    .frame(width: 32)
                                    .tintColor(.secondaryLabel)
                                label("Scroll item \(index) — edit me and save!")
                                    .font(.body)
                            }
                            .padding(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
                        }
                    }

                    spacer()
                }
                .padding(24)
            }
        }

        self.title = "Hot Reload"

        onAppear { print("[HotReloadDemoScreen] appeared — tap count: \(viewModel.state.tapCount)") }
    }
}
