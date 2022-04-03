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
        conditionTypeId: String,
        literal: Int? = nil,
        fieldId: String? = nil,
        loadableId: String? = nil
    ) -> ConditionEvaluable {
        guard let type = ConditionType.getEnum(by: conditionTypeId) else {
            fatalError("condition type not found")
        }
        let loadable = type.getStorageDependencies()?.first { $0.id == loadableId }
        switch type {
        case .metaLevel:
            guard let loadable = loadable,
                  let fieldId = fieldId,
                  let namedKeyPath = MetaLevel.getNamedKeyPath(given: fieldId)  else {
                fatalError("should not be nil")
            }
            return .metaLevel(
                loadable: loadable,
                evaluatingKeyPath: namedKeyPath
            )
        case .level:
            guard let loadable = loadable,
                  let fieldId = fieldId,
                  let namedKeyPath = Level.getNamedKeyPath(given: fieldId) else {
                fatalError("should not be nil")
            }
            return .level(loadable: loadable, evaluatingKeyPath: namedKeyPath)
        case .player:
            return .player
        case .numericLiteral:
            return .numericLiteral(-1)
        }
    }

    func buildSubject(
        conditionSubjectTypeId: String,
        subjectLiteral: Int? = nil,
        subjectFieldId: String? = nil,
        subjectLoadableId: String? = nil
    ) {
        subject = createConditionEvaluable(
            conditionTypeId: conditionSubjectTypeId,
            literal: subjectLiteral,
            fieldId: subjectFieldId,
            loadableId: subjectLoadableId
        )
    }

    func buildComparator(
        comparatorId: String
    ) {
        guard let comparator = ComparatorType.getEnum(by: comparatorId) else {
            fatalError("cannot find comparator")
        }

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
        conditionObjectTypeId: String,
        objectLiteral: Int? = nil,
        objectFieldId: String? = nil,
        objectLoadableId: String? = nil
    ) {
        object = createConditionEvaluable(
            conditionTypeId: conditionObjectTypeId,
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

protocol ConditionCreatorViewModelDelegate: AnyObject {
    func saveCondition(_ condition: Condition, entityIndex: Int)
}

class ConditionCreatorViewModel: ObservableObject {
    weak var delegate: ConditionCreatorViewModelDelegate?
    var entityIndex: Int
    @Published var selectedSubjectConditionTypeId: String?
    @Published var selectedSubjectField: String?
    @Published var selectedSubjectDependency: String?
    @Published var selectedComparatorTypeId: String?
    @Published var selectedObjectConditionTypeId: String?
    @Published var selectedObjectField: String?
    @Published var selectedObjectDependency: String?

    var tempSubjectRepresentation: String {
        guard let selectedSubjectConditionTypeId = selectedSubjectConditionTypeId else {
            return ""
        }
        return """
        \(selectedSubjectConditionTypeId)::\(selectedSubjectDependency ?? "UNKNOWN?") -> \(selectedSubjectField ?? "UNKNOWN?")
        """
    }

    var tempObjectRepresentation: String {
        guard let selectedObjectConditionTypeId = selectedObjectConditionTypeId else {
            return ""
        }
        return """
        \(selectedObjectConditionTypeId)::\(selectedObjectDependency ?? "UNKNOWN?") -> \(selectedObjectField ?? "UNKNOWN?")
        """
    }

    private var subscriptions: Set<AnyCancellable> = []

    init(entityIndex: Int) {
        self.entityIndex = entityIndex
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
        guard let selectedSubjectConditionTypeId = selectedSubjectConditionTypeId else {
            return
        }

        guard let selectedObjectConditionTypeId = selectedObjectConditionTypeId else {
            return
        }

        guard let selectedComparatorTypeId = selectedComparatorTypeId else {
            return
        }

        builder.buildSubject(
            conditionSubjectTypeId: selectedSubjectConditionTypeId,
            subjectLiteral: nil,
            subjectFieldId: selectedSubjectField,
            subjectLoadableId: selectedSubjectDependency
        )

        builder.buildComparator(comparatorId: selectedComparatorTypeId)

        builder.buildObject(
            conditionObjectTypeId: selectedObjectConditionTypeId,
            objectLiteral: nil,
            objectFieldId: selectedSubjectField,
            objectLoadableId: selectedObjectDependency
        )

        let condition = builder.getResult()
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.saveCondition(condition, entityIndex: entityIndex)
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
