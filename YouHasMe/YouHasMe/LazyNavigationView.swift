//
//  LazyNavigationView.swift
//  YouHasMe
//
//  All credits to https://stackoverflow.com/questions/57594159/
//                 swiftui-navigationlink-loads-destination-view-immediately-without-clicking
//

import SwiftUI

struct LazyNavigationView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
