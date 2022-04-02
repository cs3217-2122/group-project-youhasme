//
//  GameEventPublisher.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 2/4/22.
//

import Combine

protocol GameEventPublisher {
    var gameEventPublisher: AnyPublisher<AbstractGameEvent, Never> { get }
}
