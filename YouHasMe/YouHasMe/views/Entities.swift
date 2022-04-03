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
    EntityTypes.Nouns.flag,
    EntityTypes.Nouns.box,
    EntityTypes.Verbs.vIs,
    EntityTypes.Properties.you,
    EntityTypes.Properties.push,
    EntityTypes.Properties.stop,
    EntityTypes.Properties.win,
    EntityTypes.NounInstances.baba,
    EntityTypes.NounInstances.wall,
    EntityTypes.NounInstances.flag,
    EntityTypes.NounInstances.box
]

func entityTypeToImageString(type: EntityType) -> String {
    switch type {
    case EntityTypes.Nouns.baba:
        return "baba_text"
    case EntityTypes.Nouns.wall:
        return "wall_text"
    case EntityTypes.Nouns.flag:
        return "flag_text"
    case EntityTypes.Nouns.box:
        return "box_text"
    case EntityTypes.Verbs.vIs:
        return "is"
    case EntityTypes.Properties.you:
        return "you"
    case EntityTypes.Properties.push:
        return "push"
    case EntityTypes.Properties.stop:
        return "stop"
    case EntityTypes.Properties.win:
        return "win"
    case EntityTypes.NounInstances.baba:
        return "baba"
    case EntityTypes.NounInstances.wall:
        return "wall"
    case EntityTypes.NounInstances.flag:
        return "flag"
    case EntityTypes.NounInstances.box:
        return "box"
    default:
        return "question"
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

func metaEntityTypeToImageable(type: MetaEntityType) -> Imageable? {
    switch type {
    case .blocking:
        return .string("wall")
    case .nonBlocking:
        return .string("flag")
    case .space:
        return nil
    case .level:
        return .string("question")
    case .travel:
        return nil
    case .message:
        return nil
    }
}
