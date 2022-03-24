//
//  NavigationFrame.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

enum VerticalAlignment {
    case top
    case bottom
    case middle
}

enum HorizontalAlignment {
    case leftSide
    case rightSide
    case middle
}

typealias Runnable = () -> Void
struct NavigationFrame<Content: View>: ContainerView {
    var verticalAlignment: VerticalAlignment = .middle
    var horizontalAlignment: HorizontalAlignment = .middle

    init(content: @escaping () -> Content) {
        self.content = content
    }

    init(
        verticalAlignment: VerticalAlignment,
        horizontalAlignment: HorizontalAlignment,
        backHandler: Runnable? = nil,
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        self.init(content)
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.backHandler = backHandler
    }

    var content: () -> Content
    var backHandler: Runnable?
    var body: some View {
        VStack {
            HStack {
                if let backHandler = backHandler {
                    Button(action: backHandler, label: { Text("Back") })
                }
                Spacer()
            }
            if verticalAlignment != .top {
                Spacer()
            }
            HStack {
                if horizontalAlignment != .leftSide {
                    Spacer()
                }
                content()
                if horizontalAlignment != .rightSide {
                    Spacer()
                }
            }
            if verticalAlignment != .bottom {
                Spacer()
            }
        }
    }
}

struct NavigationFrame_Previews: PreviewProvider {
    static var previews: some View {
        NavigationFrame(verticalAlignment: .top, horizontalAlignment: .middle) {
            Text("Inner text")
        }
    }
}
