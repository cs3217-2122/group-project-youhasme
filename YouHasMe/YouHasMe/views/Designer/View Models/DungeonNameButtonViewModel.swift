//
//  DungeonNameButtonViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 8/4/22.
//

import Foundation
import Combine

class DungeonNameButtonViewModel: ObservableObject {
    @Published var name: String = ""
    private var subscriptions: Set<AnyCancellable> = []
    init(namePublisher: AnyPublisher<String, Never>) {
        namePublisher
            .sink { [weak self] name in self?.name = name }
            .store(in: &subscriptions)
    }
}
