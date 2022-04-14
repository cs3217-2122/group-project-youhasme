//
//  PreloadedAchievementsUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 14/4/22.
//

import Foundation

struct PreloadedAchievementsUtil {
    static func getDesignLevelAchievement() -> Achievement {
        let designStat1 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .designLevel))
        let designUnlockCondition1 = IntegerUnlockCondition(statistic: designStat1, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                            unlockValue: 1)
        return Achievement(name: "Creativity", description: "Create your first level",
                           unlockConditions: [designUnlockCondition1])
    }

    static func getTenMovesAchievement() -> Achievement {
        let moveStat1 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .move))
        let moveUnlockCondition1 = IntegerUnlockCondition(statistic: moveStat1, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                          unlockValue: 10)
        return Achievement(name: "Baby Steps", description: "Move 10 Steps in Total",
                           unlockConditions: [moveUnlockCondition1])
    }

    static func getWinLevelLimitedMovesAchievement() -> Achievement {
        let levelName = "Big Brain"
        let numMoves = 10
        let levelMoveStat1 = GameStatistic(value: 0, statisticType: .level,
                                           gameEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .move),
                                                                          levelName: levelName))
        let levelMoveUnlockCondition1 = IntegerUnlockCondition(statistic: levelMoveStat1,
                                                               comparison: .LESS_THAN, unlockValue: numMoves)
        let levelWinStat1 = GameStatistic(value: 0, statisticType: .level,
                                          gameEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .win),
                                                                         levelName: levelName))
        let levelWinUnlockCondition1 = IntegerUnlockCondition(statistic: levelWinStat1,
                                                              comparison: .MORE_THAN_OR_EQUAL_TO, unlockValue: 1)
        return Achievement(name: "Speedy Game", description: "Win Level \(levelName) in Less than \(numMoves) Moves",
                           unlockConditions: [levelMoveUnlockCondition1, levelWinUnlockCondition1])
    }

    static func getOneMillionMovesAchievement() -> Achievement {
        let moveStat = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .move))
        let moveUnlockCondition = IntegerUnlockCondition(statistic: moveStat, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                         unlockValue: 1_000_000)
        return Achievement(name: "Over One Million", description: "Move 1,000,000 Steps in Total",
                           unlockConditions: [moveUnlockCondition])
    }

    static func getHiddenAchievement() -> Achievement {
        let winEvent = GameEvent(type: .win)
        let event = EntityEventDecorator(wrappedEvent: winEvent, entityType: EntityTypes.NounInstances.baba)
        let statistic = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: event)
        let unlockCondition = IntegerUnlockCondition(statistic: statistic, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                     unlockValue: 1)
        return Achievement(name: "GOGO IS YOU", description: "Win a level as Gogo",
                           unlockConditions: [unlockCondition], isHidden: true)
    }

    static func getPreloadedAchievements() -> [Achievement] {
        let achievements = [
             getDesignLevelAchievement(),
             getTenMovesAchievement(),
             getWinLevelLimitedMovesAchievement(),
             getOneMillionMovesAchievement(),
             getHiddenAchievement()
         ]
         return achievements
     }
}
