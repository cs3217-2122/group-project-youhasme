//
//  ContainerView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import Foundation
import SwiftUI

// reference: https://www.swiftbysundell.com/tips/creating-custom-swiftui-container-views/
protocol ContainerView: View {
    associatedtype Content
    init(content: @escaping () -> Content)
}

extension ContainerView {
    init(@ViewBuilder _ content: @escaping () -> Content) {
        self.init(content: content)
    }
}
