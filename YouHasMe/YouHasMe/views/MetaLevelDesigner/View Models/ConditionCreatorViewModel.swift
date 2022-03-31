//
//  ConditionCreatorViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 31/3/22.
//

import Foundation
import Combine
class ConditionBuilder {
    var subject: ConditionEvaluable?
    var relation: ConditionRelation?
    var object: ConditionEvaluable?

    private func createConditionEvaluable(
        type: ConditionType,
        literal: Int? = nil,
        fieldId: String? = nil,
        loadableId: String? = nil
    ) -> ConditionEvaluable {
        let loadable = type.getStorageDependencies()?.first { $0.id == loadableId }
        let namedKeyPath = type.getKeyPaths().first { $0.id == fieldId }
        switch type {
        case .metaLevel:
            guard let loadable = loadable,
                  let namedKeyPath = namedKeyPath  else {
                fatalError("should not be nil")
            }
            return .metaLevel(
                loadable: loadable,
                evaluatingKeyPath: NamedKeyPath(id: namedKeyPath.id, keyPath: namedKeyPath.keyPath as! KeyPath<MetaLevel, Int>)
            )
        case .level:
            guard let loadable = loadable,
                  let namedKeyPath = namedKeyPath  else {
                fatalError("should not be nil")
            }
            return .level(loadable: loadable, evaluatingKeyPath: NamedKeyPath(id: namedKeyPath.id, keyPath: namedKeyPath.keyPath as! KeyPath<Level, Int>))
        case .player:
            return .player
        case .numericLiteral:
            return .numericLiteral(-1)
        }
    }

    func buildSubject(
        conditionSubjectType: ConditionType,
        subjectLiteral: Int? = nil,
        subjectFieldId: String? = nil,
        subjectLoadableId: String? = nil
    ) {
        subject = createConditionEvaluable(
            type: conditionSubjectType,
            literal: subjectLiteral,
            fieldId: subjectFieldId,
            loadableId: subjectLoadableId
        )
    }

    func buildComparator(
        comparator: ComparatorType
    ) {
        switch comparator {
        case .eq:
            relation = .eq
        case .geq:
            relation = .geq
        case .leq:
            relation = .leq
        case .lt:
            relation = .lt
        case .gt:
            relation = .gt
        }
    }

    func buildObject(
        conditionObjectType: ConditionType,
        objectLiteral: Int? = nil,
        objectFieldId: String? = nil,
        objectLoadableId: String? = nil
    ) {
        object = createConditionEvaluable(
            type: conditionObjectType,
            literal: objectLiteral,
            fieldId: objectFieldId,
            loadableId: objectLoadableId
        )
    }

    func getResult() -> Condition {
        guard let subject = subject, let relation = relation, let object = object else {
            fatalError("build failed")
        }

        return Condition(subject: subject, relation: relation, object: object)
    }
}

class ConditionCreatorViewModel: ObservableObject {
    @Published var selectedSubjectConditionTypeId: String?
    @Published var selectedSubjectField: String?
    @Published var selectedSubjectDependency: String?
    @Published var selectedComparatorTypeId: String?
    @Published var selectedObjectConditionTypeId: String?
    @Published var selectedObjectField: String?
    @Published var selectedObjectDependency: String?

    private var subscriptions: Set<AnyCancellable> = []

    init() {
        setupBindings()
    }

    private func setupBindings() {
        $selectedSubjectConditionTypeId.removeDuplicates().sink { [weak self] _ in
            self?.resetSubjectDetails()
        }.store(in: &subscriptions)

        $selectedObjectConditionTypeId.removeDuplicates().sink { [weak self] _ in
            self?.resetObjectDetails()
        }.store(in: &subscriptions)
    }

    func resetSubjectDetails() {
        selectedSubjectField = nil
        selectedSubjectDependency = nil
    }

    func resetObjectDetails() {
        selectedObjectField = nil
        selectedObjectDependency = nil
    }
    
    func saveCondition() {
        let builder = ConditionBuilder()
        builder.buildSubject(
            conditionSubjectType: <#T##ConditionType#>,
            subjectLiteral: <#T##Int?#>,
            subjectFieldId: <#T##String?#>,
            subjectLoadableId: <#T##String?#>
        )
        
        builder.buildComparator(comparator: <#T##ComparatorType#>)
        
        builder.buildObject(
            conditionObjectType: <#T##ConditionType#>,
            objectLiteral: <#T##Int?#>,
            objectFieldId: <#T##String?#>,
            objectLoadableId: <#T##String?#>
        )
        
        let condition = builder.getResult()
    }
}

enum ConditionType: String {
    case metaLevel = "Meta Level"
    case level = "Level"
    case player = "Player"
    case numericLiteral = "Numeric"

    func getKeyPaths() -> [AnyNamedKeyPath] {
        switch self {
        case .metaLevel:
            return MetaLevel.typeErasedNamedKeyPaths
        case .level:
            return Level.typeErasedNamedKeyPaths
        case .player:
            return []
        case .numericLiteral:
            return []
        }
    }

    func getStorageDependencies() -> [Loadable]? {
        switch self {
        case .metaLevel:
            return MetaLevelStorage().getAllLoadables()
        case .level:
            return LevelStorage().getAllLoadables()
        case .player:
            return nil
        case .numericLiteral:
            return nil
        }
    }
}

extension ConditionType: CaseIterable {}
extension ConditionType: Identifiable {
    var id: String {
        rawValue
    }

    static func getEnum(by id: String) -> ConditionType? {
        ConditionType.allCases.first { $0.id == id }
    }
}
extension ConditionType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

enum ComparatorType: String {
    case eq = "="
    case geq = ">="
    case leq = "<="
    case lt = "<"
    case gt = ">"
}
extension ComparatorType: CaseIterable {}
extension ComparatorType: Identifiable {
    var id: String {
        rawValue
    }

    static func getEnum(by id: String) -> ComparatorType? {
        ComparatorType.allCases.first { $0.id == id }
    }
}
extension ComparatorType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
