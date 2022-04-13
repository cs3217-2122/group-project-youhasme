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
    var dungeonId: String
    var levelId: String?
    var storage = AchievementStorage()
    private var subscriptions = [AnyCancellable]()

    var levelStatistics: [GameStatistic] {
        lockedAchievements.flatMap { $0.getLevelStatistics() }
    }

    init(dungeonId: String = "") {
        let achievements: [Achievement] = storage.loadAllAchievements()
        for achievement in achievements {
            if achievement.isUnlocked {
                unlockedAchievements.append(achievement)
            } else {
                lockedAchievements.append(achievement)
            }
        }
        self.dungeonId = dungeonId
        resetLevelStats()
    }

    func selectLevel(level: Level) {
        levelId = level.id.dataString
        resetLevelStats()
    }

    func resetLevelStats() {
        levelStatistics.forEach { $0.reset() }
    }

    func resetSubscriptions() {
        subscriptions.removeAll()
    }

    func setSubscriptionsFor(_ gameEventPublisher: AnyPublisher<AbstractGameEvent, Never>) {
        gameEventPublisher.sink { [weak self] gameEvent in
            guard let self = self else {
                return
            }
            var gameEvent = gameEvent
            if let levelId = self.levelId {
                gameEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelName: levelId)
            }

            for achievement in self.lockedAchievements {
                self.updateAchievement(achievement, gameEvent: gameEvent)
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

    func updateData() {
        let achievements: [Achievement] = storage.loadAllAchievements()
        lockedAchievements = []
        unlockedAchievements = []
        for achievement in achievements {
            if achievement.isUnlocked {
                unlockedAchievements.append(achievement)
            } else {
                lockedAchievements.append(achievement)
            }
        }
    }
}
