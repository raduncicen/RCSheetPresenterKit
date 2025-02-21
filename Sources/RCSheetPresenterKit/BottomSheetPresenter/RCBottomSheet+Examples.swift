//
//  RCBottomSheet+Examples.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 20.02.2025.
//
import RCPreviewKit
import SwiftUI

struct SampleParentView: View {
    @ObservedObject var viewModel: SampleParentViewModel

    var body: some View {
        ZStack {
            Color(uiColor: .separator)
                .ignoresSafeArea()

            VStack {
                ForEach(SampleParentViewModel.Presets.allCases, id: \.self) { preset in
                    Button(action: { viewModel.presentSheet(preset: preset) }) {
                        Text(preset.rawValue)
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(.blue))
                            .padding(.horizontal)

                    }
                }

                Spacer()
            }
            .navigationTitle("PARENT VIEW")
        }
    }
}

struct SampleChildView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            Button(action: { dismiss() }) {
                Text("Dismiss")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(RoundedRectangle(cornerRadius: 12).foregroundStyle(.blue))
                    .padding(.horizontal)
            }

            Text("This is your child view with some lorem ipsum text\n\n")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .background(.yellow)
    }
}

class SampleParentViewModel: ObservableObject {

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func presentSheet(preset: Presets) {
        switch preset {
        case .mediumLargeSheet:
            showMediumLargeSheet()
        case .mediumLargeDismissableSheet:
            showMediumLargeDismissableSheet()
        case .selfSizedSheet:
            showSelfSizedSheet()
        case .selfSizedExpandableSheet:
            showSelfSizedExpandableSheet()
        case .programmaticallyChangeDetent:
            programmaticallyChangeDetent()
        }
    }

    private func showMediumLargeSheet() {
        RCBottomSheetPresenter(navigationController: navigationController)
            .presentBottomSheet(
                view: SampleChildView(),
                detentConfiguration: .init(
                    detents: [
                        .medium,
                        .large
                    ]
                    ,largestUndimmedDetent: .detent(.medium)
                ),
                uiConfiguration: .init(
                    showsGrabIndicator: true,
                    enableInteractiveDismiss: false,
                    preferredCornerRadius: 32
                )
            )
    }

    private func showMediumLargeDismissableSheet() {
        RCBottomSheetPresenter(navigationController: navigationController)
            .presentBottomSheet(
                view: SampleChildView(),
                detentConfiguration: .init(
                    detents: [
                        .medium,
                        .large
                    ]
                    ,largestUndimmedDetent: .selfSized
                ),
                uiConfiguration: .init(
                    showsGrabIndicator: true,
                    enableInteractiveDismiss: true,
                    preferredCornerRadius: 32
                )
            )
    }

    private func showSelfSizedSheet() {
        RCBottomSheetPresenter(navigationController: navigationController)
            .presentBottomSheet(
                view: SampleChildView(),
                detentConfiguration: .init(
                    detents: [
                        .selfSizing(fallback: .large),
                    ]
                    ,largestUndimmedDetent: .selfSized
                ),
                uiConfiguration: .init(
                    showsGrabIndicator: true,
                    enableInteractiveDismiss: false,
                    preferredCornerRadius: 32
                )
            )
    }

    private func showSelfSizedExpandableSheet() {
        RCBottomSheetPresenter(navigationController: navigationController)
            .presentBottomSheet(
                view: SampleChildView(),
                detentConfiguration: .init(
                    detents: [
                        .selfSizing(fallback: .large),
                        .large
                    ]
                    ,largestUndimmedDetent: .selfSized
                ),
                uiConfiguration: .init(
                    showsGrabIndicator: true,
                    enableInteractiveDismiss: false,
                    preferredCornerRadius: 32
                )
            )
    }

    private func programmaticallyChangeDetent() {
        let (sheetController, detents) = RCBottomSheetPresenter(navigationController: navigationController)
            .presentBottomSheet(
                view: SampleChildView(),
                detentConfiguration: .init(
                    detents: [
                        .custom(height: 200, fallBack: .large),
                        .medium,
                        .large,
                    ]
                    ,largestUndimmedDetent: .detent(.medium)
                ),
                uiConfiguration: .init(
                    showsGrabIndicator: true,
                    enableInteractiveDismiss: false,
                    preferredCornerRadius: 32
                )
            )

        guard let sheetController, sheetController.detents.count > 1 else { return }

//         If you wish you can set the initial start detent as below.
        if #available(iOS 16.0, *) {
            sheetController.selectedDetentIdentifier = detents[.medium]?.identifier
        } else {
            sheetController.selectedDetentIdentifier = .medium
        }

        // You can change it at any given point in time.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            sheetController.animateChanges {
                if #available(iOS 16.0, *) {
                    sheetController.selectedDetentIdentifier = detents[.large]?.identifier
                } else {
                    sheetController.selectedDetentIdentifier = .large
                }
            }
        }
    }

    enum Presets: String, CaseIterable {
        case mediumLargeSheet
        case mediumLargeDismissableSheet
        case selfSizedSheet
        case selfSizedExpandableSheet
        case programmaticallyChangeDetent
    }
}

// MARK: - Preview

#Preview("Sheet Examples") {
    RCPreviewer { navigationController in
        let viewModel = SampleParentViewModel(navigationController: navigationController)
        let viewController = UIHostingController(rootView: SampleParentView(viewModel: viewModel))
        return viewController
    }
    .ignoresSafeArea()
}
