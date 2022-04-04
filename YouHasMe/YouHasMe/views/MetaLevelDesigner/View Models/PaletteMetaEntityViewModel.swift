//
//  PaletteMetaEntityViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import Foundation
import Combine

protocol PaletteMetaEntityViewModelDelegate: AnyObject {
    func selectPaletteMetaEntity(_ metaEntity: MetaEntityType)
    var selectedPaletteMetaEntityPublisher: AnyPublisher<MetaEntityType?, Never> { get }
}

class PaletteMetaEntityViewModel: CellViewModel {
    weak var delegate: PaletteMetaEntityViewModelDelegate? {
        didSet {
            guard delegate != nil else {
                return
            }
            setupBindingsWithDelegate()
        }
    }
    private var metaEntity: MetaEntityType
    var shouldHighlightPublisher: AnyPublisher<Bool, Never> {
        shouldHighlight.eraseToAnyPublisher()
    }
    private var shouldHighlight: PassthroughSubject<Bool, Never> = PassthroughSubject()
    private var subscriptions: Set<AnyCancellable> = []

    init(metaEntity: MetaEntityType) {
        self.metaEntity = metaEntity
        super.init(imageSource: metaEntityTypeToImageable(type: metaEntity))
    }

    func select() {
        guard let delegate = delegate else {
            return
        }
        delegate.selectPaletteMetaEntity(metaEntity)
    }

    func setupBindingsWithDelegate() {
        guard let delegate = delegate else {
            fatalError("should not be nil")
        }

        delegate.selectedPaletteMetaEntityPublisher
            .sink { [weak self] selectedPaletteMetaEntity in
                guard let self = self else {
                    return
                }

                self.shouldHighlight.send(selectedPaletteMetaEntity == self.metaEntity)
            }
            .store(in: &subscriptions)
    }
}

extension PaletteMetaEntityViewModel: Hashable {
    static func == (lhs: PaletteMetaEntityViewModel, rhs: PaletteMetaEntityViewModel) -> Bool {
        lhs.metaEntity == rhs.metaEntity
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(metaEntity)
    }
}
