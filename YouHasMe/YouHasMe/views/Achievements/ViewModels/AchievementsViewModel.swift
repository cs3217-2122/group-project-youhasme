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
    private var cancellables = [AnyCancellable]()
    private var statistics = Statistics()

    init() {
        // jx todo: implement pre-loaded achievements
        // let achievements = loadAchievements()
        self.lockedAchievements = [
//            Achievement(name: "Design your first level", unlockConditions: [EventUnlockCondition(eventType: )]),
//            Achievement(name: "Win level Abc", unlockConditions: [EventUnlockCondition(eventType: .WIN, )])
            Achievement(name: "Move 10 steps in total",
                        unlockConditions: [NumericUnlockCondition(statistics: statistics,
                                                                  statisticName: "Lifetime Moves",
                                                                  comparison: .MORE_THAN_OR_EQUAL_TO, unlockValue: 10)])
        ]
    }

    func resetLevelStats() {
        statistics.resetLevelStats()
    }

    func setSubscriptionsFor(_ engine: GameEngine) {
        engine.gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }

            switch gameEvent.type {
            case .MOVE:
                self.statistics.addMove()
            case .WIN:
                self.statistics.addWin()
            }

            for achievement in self.lockedAchievements {
                achievement.unlockIfConditionsMet()
                if achievement.isUnlocked {
                    self.lockedAchievements.removeByIdentity(achievement)
                    self.unlockedAchievements.append(achievement)
                }
            }
        }.store(in: &cancellables)
    }
}
