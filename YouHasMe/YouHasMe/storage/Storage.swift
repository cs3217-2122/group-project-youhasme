//
//  Storage.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 22/3/22.
//

import Foundation

/// Handles all local storage operations like reading, writing to a file.
///
/// Example:
/// 1. Suppose a user wants to conduct file operations with image files, say of format `png`
/// ```
/// var pngStorage = Storage(fileExtension: "png")
/// ```
class Storage {
    private static let defaultDirectoryName = "YouHasMe"
    /// The file extension associated with this storage object, so that all files read and written
    /// are appended with this extension.
    let fileExtension: String

    init(fileExtension: String) {
        self.fileExtension = fileExtension
    }

    func getDefaultDirectory() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(Storage.defaultDirectoryName, isDirectory: true)
    }

    final func rename(source: URL, to destination: URL) throws {
        try FileManager.default.moveItem(at: source, to: destination)
    }

    final func getURL(filename: String) throws -> URL {
        let directoryUrl = try getDefaultDirectory()
        try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
        return directoryUrl.appendingPathComponent(filename)
            .appendingPathExtension(fileExtension)
    }

    final func getURL(directoryName: String, createIfNotExists: Bool) throws -> URL {
        let directoryUrl = try getDefaultDirectory().appendingPathComponent(directoryName)
        if createIfNotExists {
            try FileManager.default.createDirectory(
                at: directoryUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        return directoryUrl
    }

    final func save(data: Data, to file: URL) throws {
        try data.write(to: file)
    }

    final func load(from file: URL) throws -> Data {
        try Data(contentsOf: file)
    }

    final func delete(file: URL) throws {
        try FileManager.default.removeItem(at: file)
    }

    final func getAllFiles(in directory: URL) -> (urls: [URL], filenames: [String]) {
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: directory, includingPropertiesForKeys: nil, options: [])
            let urlsWithSelectedFileExtension = urls.filter({ $0.pathExtension == fileExtension })
            let filenames = urlsWithSelectedFileExtension.map { $0.deletingPathExtension().lastPathComponent }
            return (urlsWithSelectedFileExtension, filenames)
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return ([], [])
    }

    final func getAllLoadables(in directory: URL) -> [Loadable] {
        do {
            let urls = try FileManager.default.contentsOfDirectory(
                at: directory, includingPropertiesForKeys: nil, options: [])
            let urlsWithSelectedFileExtension = urls.filter({ $0.pathExtension == fileExtension })
            let loadables = urlsWithSelectedFileExtension.map {
                Loadable(
                    url: $0,
                    name: $0.deletingPathExtension().lastPathComponent
                )
            }
            return loadables
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return []
    }
}

extension Storage {
    func save(data: Data, filename: String) throws {
        try save(data: data, to: getURL(filename: filename))
    }

    func load(filename: String) throws -> Data {
        try load(from: getURL(filename: filename))
    }

    func delete(filename: String) throws {
        try delete(file: getURL(filename: filename))
    }

    func getAllFiles() -> (urls: [URL], filenames: [String]) {
        do {
            return try getAllFiles(in: getDefaultDirectory())
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return ([], [])
    }

    func getAllLoadables() -> [Loadable] {
        do {
            return try getAllLoadables(in: getDefaultDirectory())
        } catch {
            globalLogger.error(error.localizedDescription)
        }
        return []
    }
}

/// A specialization of the `Storage` class used with interacting with json files. In addition to the base class's
/// read and write operations, `JSONStorage` also handles encoding to json and decoding from json.
class JSONStorage: Storage {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init() {
        super.init(fileExtension: "json")
    }

    final func encode<T: Encodable>(object: T) throws -> Data {
        let result = try encoder.encode(object)
        return result
    }

    final func encodeAndSave<T: Encodable>(object: T, to file: URL) throws {
        try save(data: encode(object: object), to: file)
    }

    final func decode<T: Decodable>(data: Data) throws -> T {
        try decoder.decode(T.self, from: data)
    }

    final func loadAndDecode<T: Decodable>(from file: URL) throws -> T {
        try decode(data: load(from: file))
    }

}

extension JSONStorage {
    func encodeAndSave<T: Encodable>(object: T, filename: String) throws {
        try encodeAndSave(object: object, to: getURL(filename: filename))
    }

    func loadAndDecode<T: Decodable>(filename: String) throws -> T {
        try loadAndDecode(from: getURL(filename: filename))
    }
}

class LevelStorage: JSONStorage {
    static let levelDirectoryName: String = "Levels"
    static let defaultFileStorageName = "TestDataFile1"
    static let preloadedLevelNames: [String] = []
    let dungeonDirectory: URL

    init(dungeonDirectory: URL) {
        self.dungeonDirectory = dungeonDirectory
    }

    override func getDefaultDirectory() -> URL {
        dungeonDirectory.appendingPathComponent(LevelStorage.levelDirectoryName)
    }

    func loadLevel(_ dataStringConvertible: DataStringConvertible) -> PersistableLevel? {
        try? loadAndDecode(filename: dataStringConvertible.dataString)
    }

    func loadLevel(_ dataStringConvertible: DataStringConvertible) -> Level? {
        guard let persistableLevel: PersistableLevel = loadLevel(dataStringConvertible) else {
            return nil
        }
        return Level.fromPersistable(persistableLevel)
    }

    func saveLevel(_ level: Level) throws {
        try encodeAndSave(object: level.toPersistable(), filename: level.id.dataString)
    }
}

class DungeonStorage: JSONStorage {
    static let dungeonDirectoryName: String = "Dungeons"

    override func getDefaultDirectory() throws -> URL {
        try super.getDefaultDirectory().appendingPathComponent(DungeonStorage.dungeonDirectoryName)
    }

    func loadDungeon(name: String) throws -> PersistableDungeon {
        try loadAndDecode(filename: name)
    }

    func loadDungeon(name: String) -> Dungeon? {
        guard let persistableDungeon: PersistableDungeon = try? loadAndDecode(filename: name) else {
            return nil
        }

        return Dungeon.fromPersistable(persistableDungeon)
    }

    func renameDungeon(from oldName: String, to newName: String) throws {
        let oldDungeonURL = try getURL(filename: oldName)
        let newDungeonURL = try getURL(filename: newName)
        let oldLevelDirectory = try getURL(
            directoryName: oldName,
            createIfNotExists: false
        )
        let newLevelDirectory = try getURL(
            directoryName: newName,
            createIfNotExists: false
        )
        try rename(source: oldDungeonURL, to: newDungeonURL)
        try rename(source: oldLevelDirectory, to: newLevelDirectory)
    }

    func saveDungeon(_ dungeon: Dungeon) throws {
        try encodeAndSave(object: dungeon.toPersistable(), filename: dungeon.name)
    }

    func getLevelStorage(for dungeonName: String) throws -> LevelStorage {
        try LevelStorage(dungeonDirectory: getDefaultDirectory().appendingPathComponent(dungeonName))
    }

}

class AchievementStorage: JSONStorage {
    static let achievementStorageDirectoryName: String = "Achievements"

    override func getDefaultDirectory() throws -> URL {
        try super.getDefaultDirectory().appendingPathComponent(AchievementStorage.achievementStorageDirectoryName)
    }

    func loadAchievement(name: String) throws -> PersistableAchievement {
        try loadAndDecode(filename: name)
    }

    func loadAchievement(name: String) -> Achievement? {
        guard let persistableAchievement: PersistableAchievement = try? loadAndDecode(filename: name) else {
            print("could not load achievement from file called \(name)")
            return nil
        }

        return Achievement.fromPersistable(persistable: persistableAchievement)
    }

    func saveAchievement(_ achievement: Achievement) throws {
        try encodeAndSave(object: achievement.toPersistable(), filename: achievement.name)
    }

    func loadAllAchievements() -> [Achievement] {
        let (_, filenames) = AchievementStorage().getAllFiles()
        var allAchievements = filenames.compactMap { loadAchievement(name: $0) }

        let preloadedAchievements = preloadedAchievements()
        for preloaded in preloadedAchievements {
            if !allAchievements.contains(where: { $0.name == preloaded.name }) {
                allAchievements.append(preloaded)
            }
        }
        return allAchievements
    }

    func getDesignLevelAchievement() -> Achievement {
        let designStat1 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .designLevel))
        let designUnlockCondition1 = IntegerUnlockCondition(statistic: designStat1, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                            unlockValue: 1)
        return Achievement(name: "Creativity", description: "Create your first level",
                           unlockConditions: [designUnlockCondition1])
    }

    func getTenMovesAchievement() -> Achievement {
        let moveStat1 = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .move))
        let moveUnlockCondition1 = IntegerUnlockCondition(statistic: moveStat1, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                          unlockValue: 10)
        return Achievement(name: "Baby Steps", description: "Move 10 Steps in Total",
                           unlockConditions: [moveUnlockCondition1])
    }

    func getWinLevelLimitedMovesAchievement() -> Achievement {
        let levelMoveStat1 = GameStatistic(value: 0, statisticType: .level,
                                           gameEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .move),
                                                                          levelName: "Abc"))
        let levelMoveUnlockCondition1 = IntegerUnlockCondition(statistic: levelMoveStat1,
                                                               comparison: .LESS_THAN, unlockValue: 10)
        let levelWinStat1 = GameStatistic(value: 0, statisticType: .level,
                                          gameEvent: LevelEventDecorator(wrappedEvent: GameEvent(type: .win),
                                                                         levelName: "Abc"))
        let levelWinUnlockCondition1 = IntegerUnlockCondition(statistic: levelWinStat1,
                                                              comparison: .MORE_THAN_OR_EQUAL_TO, unlockValue: 1)
        return Achievement(name: "Speedy Game", description: "Win Level Abc in Less than 10 Moves",
                           unlockConditions: [levelMoveUnlockCondition1, levelWinUnlockCondition1])
    }

    func getOneMillionMovesAchievement() -> Achievement {
        let moveStat = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: GameEvent(type: .move))
        let moveUnlockCondition = IntegerUnlockCondition(statistic: moveStat, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                         unlockValue: 1_000_000)
        return Achievement(name: "Over One Million", description: "Move 1,000,000 Steps in Total",
                           unlockConditions: [moveUnlockCondition])
    }

    func getHiddenAchievement() -> Achievement {
        let winEvent = GameEvent(type: .win)
        let event = EntityEventDecorator(wrappedEvent: winEvent, entityType: EntityTypes.NounInstances.baba)
        let statistic = GameStatistic(value: 0, statisticType: .lifetime, gameEvent: event)
        let unlockCondition = IntegerUnlockCondition(statistic: statistic, comparison: .MORE_THAN_OR_EQUAL_TO,
                                                     unlockValue: 1)
        return Achievement(name: "You are Baba", description: "Win a level as Baba",
                           unlockConditions: [unlockCondition], isHidden: true)
    }

    func preloadedAchievements() -> [Achievement] {
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
