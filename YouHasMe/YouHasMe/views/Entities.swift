//
//  Entities.swift
//  YouHasMe
//

import Foundation
import SwiftUI
 
let allAvailableEntityTypes: [EntityType] = [
    EntityTypes.Nouns.baba,
    EntityTypes.Nouns.wall,
    EntityTypes.Nouns.skull,
    EntityTypes.Nouns.flag,
    EntityTypes.Connectives.and,
    EntityTypes.Verbs.vIs,
    EntityTypes.Verbs.vHas,
    EntityTypes.Properties.you,
    EntityTypes.Properties.win,
    EntityTypes.Properties.defeat,
    EntityTypes.Properties.block
]


func entityTypeToImageString(type: EntityType) -> Color {
    switch type {
    case EntityTypes.Nouns.baba:
        return .red
    case EntityTypes.Nouns.wall:
        return .yellow
    case EntityTypes.Nouns.skull:
        return .blue
    case EntityTypes.Nouns.flag:
        return .purple
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
    default:
        return .gray
    }
}
