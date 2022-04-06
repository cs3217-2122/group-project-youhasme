//
//  NamedKeyPath.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
struct AnyNamedKeyPath: Identifiable {
    var id: String
    var keyPath: AnyKeyPath
}

extension AnyNamedKeyPath: CustomStringConvertible {
    var description: String {
        id
    }
}

struct NamedKeyPath<Identifier, PathRoot, Value>: Identifiable
where Identifier: Codable & Hashable & CustomStringConvertible {
    var id: Identifier
    var keyPath: KeyPath<PathRoot, Value>

    func eraseToAnyKeyPath() -> AnyNamedKeyPath {
        AnyNamedKeyPath(id: id.description, keyPath: keyPath)
    }
}

extension NamedKeyPath {
    func toPersistable() -> PersistableNamedKeyPath<Identifier> {
        PersistableNamedKeyPath(id: id)
    }
}

extension NamedKeyPath: CustomStringConvertible {
    var description: String {
        id.description
    }
}

extension NamedKeyPath: Hashable {}

struct PersistableNamedKeyPath<Identifier>: Codable
where Identifier: Codable & Hashable & CustomStringConvertible {
    var id: Identifier
}
