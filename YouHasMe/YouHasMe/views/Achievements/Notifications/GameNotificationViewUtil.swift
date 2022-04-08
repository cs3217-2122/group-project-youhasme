//
//  GameNotificationViewUtil.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation

struct GameNotificationViewUtil {
    static func handleRemoveGameNotification(
        viewModel: GameNotificationsViewModel, toRemove: GameNotification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("dispatchq")
            viewModel.hasFinishedShowing(toRemove)
        }
    }
}
