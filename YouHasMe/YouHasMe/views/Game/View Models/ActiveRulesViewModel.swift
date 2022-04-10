//
//  ActiveRulesViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import Foundation
import Combine

class ActiveRulesViewModel: ObservableObject {
    @Published var activeRules: [Rule] = []
    private var subscriptions: Set<AnyCancellable> = []
    init(lastActiveRulesPublisher: AnyPublisher<[Rule], Never>) {
        lastActiveRulesPublisher.sink { [weak self] in
            self?.activeRules = $0
        }.store(in: &subscriptions)
    }
}
