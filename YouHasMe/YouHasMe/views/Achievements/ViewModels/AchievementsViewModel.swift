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
    var levelId: String
    private var subscriptions = [AnyCancellable]()

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
        resetLevelStats()
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

            let updatedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: self.levelId)

            for achievement in self.lockedAchievements {
                self.updateAchievement(achievement, gameEvent: updatedEvent)
                self.saveAchievement(achievement)
                self.updateLockedUnlockedAchievements(updatedAchievement: achievement)

            }
        }.store(in: &subscriptions)
    }

    func updateAchievement(_ achievement: Achievement, gameEvent: AbstractGameEvent) {
        achievement.updateStatistics(gameEvent: gameEvent)
        achievement.unlockIfConditionsMet()
    }

    func updateLockedUnlockedAchievements(updatedAchievement: Achievement) {
        if updatedAchievement.isUnlocked {
            lockedAchievements.removeByIdentity(updatedAchievement)
            unlockedAchievements.append(updatedAchievement)
        }
    }

    func saveAchievement(_ achievement: Achievement) {
        do {
            try AchievementStorage().saveAchievement(achievement)
        } catch {
            globalLogger.error("problem saving achievement \(achievement.name)")
        }
    }
}
