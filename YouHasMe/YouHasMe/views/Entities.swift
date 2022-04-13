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

func entityTypeToImageable(type: EntityType) -> Imageable {
    switch type {
    case EntityTypes.Nouns.baba:
        return .string("gogo_text")
    case EntityTypes.Nouns.wall:
        return .string("wall_text_new")
    case EntityTypes.Nouns.flag:
        return .string("flag_text_new")
    case EntityTypes.Nouns.box:
        return .string("box_text_new")
    case EntityTypes.Verbs.vIs:
        return .string("is_new")
    case EntityTypes.Properties.you:
        return .string("you_new")
    case EntityTypes.Properties.push:
        return .string("push_new")
    case EntityTypes.Properties.stop:
        return .string("stop_new")
    case EntityTypes.Properties.win:
        return .string("win_new")
    case EntityTypes.NounInstances.baba:
        return .string("gogo")
    case EntityTypes.NounInstances.wall:
        return .string("wall_new")
    case EntityTypes.NounInstances.flag:
        return .string("flag_new")
    case EntityTypes.NounInstances.box:
        return .string("box_new")
    default:
        switch type.classification {
        case .property(.player(let num)):
            return .string("\(num)")
        default:
            return .string("question")
        }
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
        return .uiColor(.gray)
    case .level:
        return .string("door")
    case .travel:
        return .string("question")
    case .message:
        return .uiColor(.darkGray)
    }
}
