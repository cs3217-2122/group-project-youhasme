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
    private var statistics = StatisticsViewModel()

    init(levelId: String = "") {
        // jx todo: implement pre-loaded achievements
        // let achievements = loadAchievements()
        self.levelId = levelId
        self.lockedAchievements = [
//            Achievement(name: "Design your first level", unlockConditions: [EventUnlockCondition(eventType: )]),
//            Achievement(name: "Win level Abc", unlockConditions: [EventUnlockCondition(eventType: .WIN, )])
            Achievement(name: "Baby Steps", description: "Move 10 Steps in Total",
                        unlockConditions: [NumericUnlockCondition(statistics: statistics,
                                                                  statisticName: "Lifetime Moves",
                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
                                                                  unlockValue: 10)]),
            Achievement(name: "Over One Million", description: "Move 1,000,000 Steps in Total",
                        unlockConditions: [NumericUnlockCondition(statistics: statistics,
                                                                  statisticName: "Lifetime Moves",
                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
                                                                  unlockValue: 1_000_000)]),
            Achievement(name: "ABC KASJHDLAKSHDLKAHDS", description: "Move 10 Steps in Level Abc",
                        unlockConditions: [NumericUnlockCondition(statistics: statistics,
                                                                  statisticName: "Level Moves for Level Abc",
                                                                  comparison: .MORE_THAN_OR_EQUAL_TO,
                                                                  unlockValue: 10)])
        ]
    }

    func selectLevel(level: Level) {
        levelId = level.id
        resetLevelStats()
    }

    func resetLevelStats() {
        statistics.resetLevelStats()
    }

    func setSubscriptionsFor(_ gameEventPublisher: AnyPublisher<AbstractGameEvent, Never>) {
        gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }

            // jx todo: refactor
            var updatedEvent = gameEvent
            if gameEvent.type != .designLevel {
                updatedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: self.levelId)
            }

            for statistic in self.statistics.gameStatistics.values {
                statistic.handleGameEvent(event: updatedEvent)
            }

            for achievement in self.lockedAchievements {
                achievement.unlockIfConditionsMet()
                if achievement.isUnlocked {
                    self.lockedAchievements.removeByIdentity(achievement)
                    self.unlockedAchievements.append(achievement)
                }
            }
        }.store(in: &subscriptions)
    }
}
