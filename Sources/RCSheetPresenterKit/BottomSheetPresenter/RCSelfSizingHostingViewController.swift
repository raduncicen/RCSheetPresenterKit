//
//  RCSelfSizingHostingViewController.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import SwiftUI

class RCSelfSizingHostingController<Content: View>: UIHostingController<Content> {

    override init(rootView: Content) {
        super.init(rootView: rootView)
        self.updatePreferredContentSize()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePreferredContentSize()
    }

    private func updatePreferredContentSize() {
        let width = UIScreen.main.bounds.width
        let height = RCSwiftUIViewSizeCalculator.calculateHeight(for: self.rootView, width: width)
        // Setting the preferredContentSize which will be used for determining the sheetSize.
        self.preferredContentSize = CGSize(width: width, height: height)
    }
}



