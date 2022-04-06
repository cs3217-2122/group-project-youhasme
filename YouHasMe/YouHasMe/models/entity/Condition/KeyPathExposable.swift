//
//  KeyPathExposable.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
protocol KeyPathExposable {
    associatedtype PathIdentifier: AbstractKeyPathIdentifierEnum
    associatedtype PathRoot
    static var exposedNumericKeyPathsMap: [PathIdentifier: KeyPath<PathRoot, Int>] { get }
    func evaluate(given keyPath: NamedKeyPath<PathIdentifier, PathRoot, Int>) -> Int
}

extension KeyPathExposable {
    static func getNamedKeyPath(given str: String) -> NamedKeyPath<PathIdentifier, PathRoot, Int> {
        getNamedKeyPath(given: PathIdentifier.getEnumByString(str))
    }

    static func getNamedKeyPath(given id: Self.PathIdentifier) -> NamedKeyPath<PathIdentifier, PathRoot, Int> {
        guard let keyPath = exposedNumericKeyPathsMap[id] else {
            fatalError("should not be nil")
        }
        return NamedKeyPath(id: id, keyPath: keyPath)
    }

    static var namedKeyPaths: [NamedKeyPath<PathIdentifier, PathRoot, Int>] {
        exposedNumericKeyPathsMap.map { NamedKeyPath(id: $0, keyPath: $1) }
    }

    static var typeErasedNamedKeyPaths: [AnyNamedKeyPath] {
        namedKeyPaths.map { $0.eraseToAnyKeyPath() }
    }

    static func keyPathfromPersistable<Identifier>(
        _ persistableNamedKeyPath: PersistableNamedKeyPath<Identifier>
    ) -> NamedKeyPath<Identifier, PathRoot, Int>? where Identifier == Self.PathIdentifier {
        let id = persistableNamedKeyPath.id
        guard let keyPath = exposedNumericKeyPathsMap[id] else {
            return nil
        }
        return NamedKeyPath(id: id, keyPath: keyPath)
    }
}
