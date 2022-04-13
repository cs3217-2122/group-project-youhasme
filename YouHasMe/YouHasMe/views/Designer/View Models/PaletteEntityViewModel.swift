//
//  PaletteEntityViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import Combine

protocol PaletteEntityViewModelDelegate: AnyObject {
    func selectPaletteEntityType(_ entityType: EntityType)
    var selectedPaletteEntityTypePublisher: AnyPublisher<EntityType?, Never> { get }
}

class PaletteEntityViewModel: CellViewModel {
    weak var delegate: PaletteEntityViewModelDelegate? {
        didSet {
            guard delegate != nil else {
                return
            }
            setupBindingsWithDelegate()
        }
    }
    private var entityType: EntityType
    var shouldHighlightPublisher: AnyPublisher<Bool, Never> {
        shouldHighlight.eraseToAnyPublisher()
    }
    private var shouldHighlight: PassthroughSubject<Bool, Never> = PassthroughSubject()
    private var subscriptions: Set<AnyCancellable> = []

    init(entityType: EntityType) {
        self.entityType = entityType
        super.init(imageSource: entityTypeToImageable(type: entityType))
    }

    func select() {
        guard let delegate = delegate else {
            return
        }
        delegate.selectPaletteEntityType(entityType)
    }

    func setupBindingsWithDelegate() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.selectedPaletteEntityTypePublisher
            .sink { [weak self] selected in
                guard let self = self else {
                    return
                }

                self.shouldHighlight.send(selected == self.entityType)
            }
            .store(in: &subscriptions)
    }
}

extension PaletteEntityViewModel: Hashable {
    static func == (lhs: PaletteEntityViewModel, rhs: PaletteEntityViewModel) -> Bool {
        lhs.entityType == rhs.entityType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(entityType)
    }
}
