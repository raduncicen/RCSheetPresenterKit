//
//  RCSelfSizingHostingViewController.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import SwiftUI

protocol RCSelfSizingViewControllerProtocol: UIViewController {
    func updatePreferredContentSize()
}

public class RCSelfSizingHostingController<Content: View>: UIHostingController<Content>, RCSelfSizingViewControllerProtocol {

    public override init(rootView: Content) {
        super.init(rootView: rootView)
        self.updatePreferredContentSize()
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePreferredContentSize()
    }

    public func updatePreferredContentSize() {
        let width = UIScreen.main.bounds.width
        let height = RCSwiftUIViewSizeCalculator.calculateHeight(for: self.rootView, width: width)
        // Setting the preferredContentSize which will be used for determining the sheetSize.
        self.preferredContentSize = CGSize(width: width, height: height)
    }
}



