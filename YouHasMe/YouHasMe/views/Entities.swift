//
//  Entities.swift
//  YouHasMe
//

import Foundation
import SwiftUI

let allAvailableEntityTypes: [EntityType] = EntityTypes.getAllEntityTypes()
let demoTypes: [EntityType] = [
    EntityTypes.Nouns.baba,
    EntityTypes.Nouns.wall,
    EntityTypes.Verbs.vIs,
    EntityTypes.Properties.you,
    EntityTypes.Properties.push,
    EntityTypes.NounInstances.baba,
    EntityTypes.NounInstances.wall
]
func entityTypeToString(type: EntityType) -> String {
    switch type {
    case EntityTypes.Nouns.baba:
        return "BABA(TEXT)"
    case EntityTypes.Nouns.wall:
        return "WALL(TEXT)"
    case EntityTypes.Verbs.vIs:
        return "IS(TEXT)"
    case EntityTypes.Properties.you:
        return "YOU(TEXT)"
    case EntityTypes.Properties.push:
        return "PUSH(TEXT)"
    case EntityTypes.NounInstances.baba:
        return "BABA"
    case EntityTypes.NounInstances.wall:
        return "WALL"
    default:
        return "UNSUPPORTED"
    }
}

func entityTypeToImageColor(type: EntityType) -> Color {
    switch type {
    case EntityTypes.Nouns.baba:
        return .red
    case EntityTypes.Nouns.wall:
        return .blue
    case EntityTypes.Nouns.skull:
        return .blue
    case EntityTypes.Nouns.flag:
        return .purple
    case EntityTypes.Nouns.word:
        return .indigo
    case EntityTypes.Connectives.and:
        return .gray
    case EntityTypes.Verbs.vIs:
        return .green
    case EntityTypes.Verbs.vHas:
        return .orange
    case EntityTypes.Properties.you:
        return .yellow
    case EntityTypes.Properties.win:
        return .cyan
    case EntityTypes.Properties.defeat:
        return .mint
    case EntityTypes.Properties.stop:
        return .gray
    case EntityTypes.NounInstances.baba:
        return .white
    case EntityTypes.NounInstances.wall:
        return .black
    case EntityTypes.NounInstances.flag:
        return .pink
    case EntityTypes.Properties.push:
        return .orange
    default:
        /// can change this if we have entity types in the future that cannot be added to the level designer
        print("Entity Type \(type.classification) does not have image")
//        assert(false, "Entity Type \(type.classification) does not have image")
        return .gray
    }
}
