//
//  AchievementsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation
import Combine

class AchievementsViewModel: ObservableObject {
    var lockedAchievements: [Achievement] = []
    var unlockedAchievements: [Achievement] = []
    var imageWidth: Float = 40
    var imageHeight: Float = 40
    var levelId: String = ""
    private var subscriptions = [AnyCancellable]()
//    private var statisticsViewModel = StatisticsViewModel()

    var levelStatistics: [GameStatistic] {
        lockedAchievements.flatMap { $0.getLevelStatistics() }
    }

    init(levelId: String = "") {
        let achievements: [Achievement] = AchievementStorage().loadAllAchievements()
        for achievement in achievements {
            if achievement.isUnlocked {
                unlockedAchievements.append(achievement)
            } else {
                lockedAchievements.append(achievement)
            }
        }
        self.levelId = levelId
    }

    func selectLevel(level: Level) {
        levelId = level.id
        resetLevelStats()
    }

    func resetLevelStats() {
        levelStatistics.forEach { $0.reset() }
    }

    func setSubscriptionsFor(_ gameEventPublisher: AnyPublisher<AbstractGameEvent, Never>) {
        gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }

            // jx todo: refactor
            var updatedEvent = gameEvent
            updatedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: self.levelId)

            for achievement in self.lockedAchievements {
                achievement.updateStatistics(gameEvent: updatedEvent)
                achievement.unlockIfConditionsMet()
                if achievement.isUnlocked {
                    self.lockedAchievements.removeByIdentity(achievement)
                    self.unlockedAchievements.append(achievement)
                }
                do {
                    try AchievementStorage().saveAchievement(achievement)
                } catch {
                    globalLogger.error("problem saving achievement \(achievement.name)")
                }
            }
        }.store(in: &subscriptions)
    }
}
