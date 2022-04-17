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
    switch type.classification {
    case .noun(let noun):
        switch noun {
        case .baba:
            return .string("baba_text")
        case .wall:
            return .string("wall_text")
        case .flag:
            return .string("flag_text")
        case .box:
            return .string("box_text")
        case .rock:
            return .string("rock_text")
        case .door:
            return .string("door_text")
        case .water:
            return .string("water_text")
        default:
            break
        }
    case .verb(let verb):
        switch verb {
        case .vIs:
            return .string("is")
        case .vHas:
            return .string("has")
        }
    case .property(let property):
        switch property {
        case .you:
            return .string("you")
        case .win:
            return .string("win")
        case .stop:
            return .string("stop")
        case .push:
            return .string("push")
        case .sink:
            return .string("sink")
        case .player(let num):
            return .sfSymbol("\(num).square")
        default:
            break
        }
    case .nounInstance(let noun):
        switch noun {
        case .baba:
            return .string("baba")
        case .wall:
            return .string("wall")
        case .flag:
            return .string("flag")
        case .box:
            return .string("box")
        case .rock:
            return .string("rock")
        case .door:
            return .string("door")
        case .water:
            return .string("water")
        default:
            break
        }
    case .conditionRelation(let relation):
        switch relation {
        case .eq:
            return .sfSymbol("equal")
        case .lt:
            return .sfSymbol("lessthan")
        case .gt:
            return .sfSymbol("greaterthan")
        default:
            return .uiImage(relation.rawValue.asImage()!)
        }
    case .conditionEvaluable(let conditionEvaluable):
        guard let value = conditionEvaluable.getValue() else {
            return .uiImage("EVAL".asImage()!)
        }
        return .uiImage("\(value)".asImage()!)
    case .connective(let connective):
        return .uiImage(connective.rawValue.asImage()!)
    }
    return .string("question")
}
