//
//  AchievementsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation
import Combine

class AchievementsViewModel: GameNotificationPublisher, ObservableObject {
    var lockedAchievements: [Achievement] = []
    var unlockedAchievements: [Achievement] = []
    var imageWidth: Float = 40
    var imageHeight: Float = 40
    var dungeonId: String
    var levelId: Point?
    var storage = AchievementStorage()
    private var subscriptions = [AnyCancellable]()
    var gameNotificationPublishingHelper = GameNotificationPublishingHelper()

    var levelStatistics: [GameStatistic] {
        lockedAchievements.flatMap { $0.getLevelStatistics() }
    }

    init(dungeonId: String = "") {
        self.dungeonId = dungeonId
        setAchievementsData()
        resetLevelStats()
    }

    func selectLevel(level: Level) {
        levelId = level.id
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

            let decoratedEvent = self.getDecoratedGameEvent(gameEvent: gameEvent)

            for achievement in self.lockedAchievements {
                self.updateAchievement(achievement, gameEvent: decoratedEvent)
                self.saveAchievement(achievement)
                self.updateLockedUnlockedAchievements(updatedAchievement: achievement)

            }
        }.store(in: &subscriptions)
    }

    func getDecoratedGameEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        var decoratedEvent = gameEvent
        if let levelId = levelId {
            decoratedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelId: levelId)
        }
        decoratedEvent = DungeonEventDecorator(wrappedEvent: gameEvent, dungeonId: dungeonId)
        return decoratedEvent
    }

    func updateAchievement(_ achievement: Achievement, gameEvent: AbstractGameEvent) {
        achievement.updateStatistics(gameEvent: gameEvent)
        achievement.unlockIfConditionsMet()
    }

    func updateLockedUnlockedAchievements(updatedAchievement: Achievement) {
        if updatedAchievement.isUnlocked {
            lockedAchievements.removeByIdentity(updatedAchievement)
            unlockedAchievements.append(updatedAchievement)
            sendGameNotification(GameNotificationViewUtil.createAchievementNotification(updatedAchievement))
        }
    }

    func saveAchievement(_ achievement: Achievement) {
        do {
            try AchievementStorage().saveAchievement(achievement)
        } catch {
            globalLogger.error("problem saving achievement \(achievement.name)")
        }
    }

    func setAchievementsData() {
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
