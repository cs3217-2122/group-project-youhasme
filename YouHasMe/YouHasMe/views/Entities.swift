//
//  Entities.swift
//  YouHasMe
//

import Foundation
import SwiftUI
 
let allAvailableEntityTypes: [EntityType] = [
    .noun(.baba),
    .noun(.wall),
    .noun(.skull),
    .noun(.flag),
    .connective(.and),
    .verb(.vIs),
    .verb(.vHas),
    .property(.you),
    .property(.win),
    .property(.defeat),
    .property(.block)
]


func entityTypeToImageString(type: EntityType) -> Color {
    switch type {
    case EntityType.noun(.baba):
        return .red
    case EntityType.noun(.wall):
        return .yellow
    case EntityType.noun(.skull):
        return .blue
    case EntityType.noun(.flag):
        return .purple
    case EntityType.connective(.and):
        return .green
    case EntityType.verb(.vIs):
        return .mint
    case EntityType.verb(.vHas):
        return .orange
    case EntityType.property(.you):
        return .brown
    case EntityType.property(.win):
        return .cyan
    case EntityType.property(.defeat):
        return .pink
    default:
        return .gray
    }
}
