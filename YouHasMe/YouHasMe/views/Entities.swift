//
//  Entities.swift
//  YouHasMe
//

import Foundation
import SwiftUI

let allAvailableEntityTypes: [EntityType] = EntityTypes.getAllEntityTypes()

func entityTypeToImageColor(type: EntityType) -> Color {
    switch type {
    case EntityTypes.Nouns.baba:
        return .red
    case EntityTypes.Nouns.wall:
        return .yellow
    case EntityTypes.Nouns.skull:
        return .blue
    case EntityTypes.Nouns.flag:
        return .purple
    case EntityTypes.Nouns.word:
        return .indigo
    case EntityTypes.Connectives.and:
        return .green
    case EntityTypes.Verbs.vIs:
        return .mint
    case EntityTypes.Verbs.vHas:
        return .orange
    case EntityTypes.Properties.you:
        return .brown
    case EntityTypes.Properties.win:
        return .cyan
    case EntityTypes.Properties.defeat:
        return .pink
    case EntityTypes.Properties.stop:
        return .gray
    default:
        /// can change this if we have entity types in the future that cannot be added to the level designer
        // TODO: implement images for entity types
        print("Entity Type \(type.classification) does not have image")
//        assert(false, "Entity Type \(type.classification) does not have image")
        return .gray
    }
}
