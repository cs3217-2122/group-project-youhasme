//
//  Loadable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
struct Loadable {
    var url: URL
    var name: String
}

extension Loadable: Identifiable {
    var id: String {
        name
    }
}

extension Loadable: Hashable {}
extension Loadable: Codable {}
