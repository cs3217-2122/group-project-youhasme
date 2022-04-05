import Foundation

struct EntityType: Hashable {
    var classification: Classification

    init(classification: Classification) {
        self.classification = classification
    }

    static func == (lhs: EntityType, rhs: EntityType) -> Bool {
        lhs.classification == rhs.classification
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(classification)
    }
}

extension EntityType {
    func toPersistable() -> PersistableEntityType {
        PersistableEntityType(classification: classification.toPersistable())
    }

    static func fromPersistable(_ persistableEntityType: PersistableEntityType) -> EntityType {
        EntityType(classification: Classification.fromPersistable(persistableEntityType.classification))
    }
}

struct EntityTypes {
    struct NounInstances {
        static var baba = EntityType(classification: .nounInstance(.baba))
        static var flag = EntityType(classification: .nounInstance(.flag))
        static var wall = EntityType(classification: .nounInstance(.wall))
        static var skull = EntityType(classification: .nounInstance(.skull))
        static var box = EntityType(classification: .nounInstance(.box))

        static func getAllNounInstances() -> [EntityType] {
            [NounInstances.baba, NounInstances.flag, NounInstances.wall, NounInstances.skull, NounInstances.box]
        }
    }

    struct Nouns {
        static var baba = EntityType(classification: .noun(.baba))
        static var flag = EntityType(classification: .noun(.flag))
        static var wall = EntityType(classification: .noun(.wall))
        static var skull = EntityType(classification: .noun(.skull))
        static var box = EntityType(classification: .noun(.box))
        static var word = EntityType(classification: .noun(.word))

        static func getAllNouns() -> [EntityType] {
            [Nouns.baba, Nouns.flag, Nouns.wall, Nouns.skull, Nouns.box, Nouns.word]
        }
    }

    struct Verbs {
        static var vIs = EntityType(classification: .verb(.vIs))
        static var vHas = EntityType(classification: .verb(.vHas))

        static func getAllVerbs() -> [EntityType] {
            [Verbs.vIs, Verbs.vHas]
        }
    }

    struct Properties {
        static var you = EntityType(classification: .property(.you))
        static var win = EntityType(classification: .property(.win))
        static var defeat = EntityType(classification: .property(.defeat))
        static var stop = EntityType(classification: .property(.stop))
        static var push = EntityType(classification: .property(.push))
        static var pull = EntityType(classification: .property(.pull))

        static func getAllProperties() -> [EntityType] {
            [
                Properties.you,
                Properties.win,
                Properties.defeat,
                Properties.stop,
                Properties.push,
                Properties.pull
            ]
        }
    }

    struct Connectives {
        static var and = EntityType(classification: .connective(.and))

        static func getAllConnectives() -> [EntityType] {
            [Connectives.and]
        }
    }

    static func getAllEntityTypes() -> [EntityType] {
        var entityTypes = NounInstances.getAllNounInstances()
        entityTypes.append(contentsOf: Nouns.getAllNouns())
        entityTypes.append(contentsOf: Verbs.getAllVerbs())
        entityTypes.append(contentsOf: Properties.getAllProperties())
        entityTypes.append(contentsOf: Connectives.getAllConnectives())
        return entityTypes
    }
}

struct PersistableEntityType {
    var classification: PersistableClassification
}

extension PersistableEntityType: Codable {}
