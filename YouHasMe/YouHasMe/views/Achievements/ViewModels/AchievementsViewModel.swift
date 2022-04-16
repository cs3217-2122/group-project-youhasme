//
//  AchievementsViewModel.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import Foundation
import Combine

class AchievementsViewModel: GameNotificationPublisher, ObservableObject {
    private(set) var lockedAchievements: [Achievement] = []
    private(set) var unlockedAchievements: [Achievement] = []
    private(set) var dungeonId: String
    private(set) var levelId: Point?
    private var storage = AchievementStorage()
    private var subscriptions = [AnyCancellable]()
    private(set) var gameNotificationPublishingHelper = GameNotificationPublishingHelper()

    private var levelStatistics: [GameStatistic] {
        lockedAchievements.flatMap { $0.getLevelStatistics() }
    }

    init(dungeonId: String = "") {
        self.dungeonId = dungeonId
        setAchievementsData()
        resetLevelStats()
    }

    func selectLevel(levelId: Point) {
        self.levelId = levelId
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

            self.updateLockedAchievements(gameEvent: decoratedEvent)
        }.store(in: &subscriptions)
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

    private func updateLockedAchievements(gameEvent: AbstractGameEvent) {
        for achievement in lockedAchievements {
            updateAchievement(achievement, gameEvent: gameEvent)
            saveAchievement(achievement)
            updateLockedUnlockedAchievements(updatedAchievement: achievement)
        }
    }

    private func getDecoratedGameEvent(gameEvent: AbstractGameEvent) -> AbstractGameEvent {
        var decoratedEvent = gameEvent
        if let levelId = levelId {
            decoratedEvent = LevelEventDecorator(wrappedEvent: gameEvent, levelId: levelId)
        }
        decoratedEvent = DungeonEventDecorator(wrappedEvent: decoratedEvent, dungeonId: dungeonId)
        return decoratedEvent
    }

    private func updateAchievement(_ achievement: Achievement, gameEvent: AbstractGameEvent) {
        achievement.updateStatistics(gameEvent: gameEvent)
        achievement.unlockIfConditionsMet()
    }

    private func updateLockedUnlockedAchievements(updatedAchievement: Achievement) {
        if updatedAchievement.isUnlocked {
            lockedAchievements.removeByIdentity(updatedAchievement)
            unlockedAchievements.append(updatedAchievement)
            sendGameNotification(GameNotificationViewUtil.createAchievementNotification(updatedAchievement))
        }
    }

    private func saveAchievement(_ achievement: Achievement) {
        do {
            try AchievementStorage().saveAchievement(achievement)
        } catch {
            globalLogger.error("problem saving achievement \(achievement.name)")
        }
    }
}
