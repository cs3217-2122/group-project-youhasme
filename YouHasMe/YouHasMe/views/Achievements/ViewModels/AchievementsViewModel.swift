//
//  AchievementsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation
import Combine

class AchievementsViewModel: ObservableObject {
    var lockedAchievements: [Achievement]
    var unlockedAchievements: [Achievement] = []
    var imageWidth: Float = 40
    var imageHeight: Float = 40
    var levelId: String = ""
    private var subscriptions = [AnyCancellable]()
    private var statisticsViewModel = StatisticsViewModel()

    init(levelId: String = "") {
        // jx todo: implement pre-loaded achievements from storage
        // let achievements = loadAchievements()
        self.levelId = levelId
        let iuc = IntegerUnlockCondition(statistic: GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .move)),
                                         comparison: .MORE_THAN_OR_EQUAL_TO, unlockValue: 10)
        self.lockedAchievements = [
//            Achievement(name: "Creativity", description: "Create your first level",
//                        unlockConditions: [IntegerUnlockCondition(statistic: GameStatistic(),
//                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
//                                                                  unlockValue: 1)]),
            Achievement(name: "Baby Steps", description: "Move 10 Steps in Total",
                        unlockConditions: [iuc])
//            ,
//            Achievement(name: "Over One Million", description: "Move 1,000,000 Steps in Total",
//                        unlockConditions: [IntegerUnlockCondition(statistics: statisticsViewModel,
//                                                                  statisticName: "Lifetime Moves",
//                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
//                                                                  unlockValue: 1_000_000)]),
//            Achievement(name: "Speedy Game", description: "Win Level Abc in Less than 10 Moves",
//                        unlockConditions: [IntegerUnlockCondition(statistics: statisticsViewModel,
//                                                                  statisticName: "Level Moves for Abc",
//                                                                  comparison: .LESS_THAN_OR_EQUAL_TO,
//                                                                  unlockValue: 10),
//                                           IntegerUnlockCondition(statistics: statisticsViewModel,
//                                                                  statisticName: "Level Wins for Abc",
//                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
//                                                                  unlockValue: 1)
//                                           ])
        ]
    }

    func selectLevel(level: Level) {
        levelId = level.id
        resetLevelStats()
    }

    func resetLevelStats() {
        statisticsViewModel.resetLevelStats()
    }

    func setSubscriptionsFor(_ gameEventPublisher: AnyPublisher<AbstractGameEvent, Never>) {
        gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }

            // jx todo: refactor
            var updatedEvent = gameEvent
            updatedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: self.levelId)

//            for statistic in self.statisticsViewModel.gameStatistics.values {
//                statistic.handleGameEvent(event: updatedEvent)
//            }

            for achievement in self.lockedAchievements {
                achievement.updateStatistics(gameEvent: updatedEvent)
                achievement.unlockIfConditionsMet()
                if achievement.isUnlocked {
                    self.lockedAchievements.removeByIdentity(achievement)
                    self.unlockedAchievements.append(achievement)
                }
            }
        }.store(in: &subscriptions)
    }
}
