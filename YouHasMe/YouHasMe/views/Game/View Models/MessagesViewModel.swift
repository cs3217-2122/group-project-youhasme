//
//  MessagesViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import Foundation
import Combine

class MessagesViewModel: ObservableObject {
    @Published var messages: [String] = []

    private var subscriptions: Set<AnyCancellable> = []

//    init(tile: MetaTile) {
//        tile.$metaEntities.sink { [weak self] metaEntities in
//            self?.messages = metaEntities.compactMap { (metaEntity: MetaEntityType) -> String? in
//                guard case .message(let text) = metaEntity else {
//                    return nil
//                }
//                return text
//            }
//        }.store(in: &subscriptions)
//    }
}
