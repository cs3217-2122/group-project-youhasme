//
//  GameNotificationView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//

import Foundation
import SwiftUI

struct GameNotificationView: View {

    var gameNotif: GameNotification
    @ObservedObject var gameNotifsViewModel: GameNotificationsViewModel

    var body: some View {
        VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(gameNotif.title)
                            .bold()
                        Text(gameNotif.subtitle)
                            .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                    }
                    Spacer()
                }
                .foregroundColor(Color.white)
                .padding(12)
                .background(.gray)
                .cornerRadius(8)
                Spacer()
        }
            .padding()
            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            .onAppear(perform: {
                GameNotificationViewUtil.handleRemoveGameNotification(
                        viewModel: gameNotifsViewModel, toRemove: gameNotif)
            })
            .onTapGesture {
                withAnimation {
                    gameNotifsViewModel.hasFinishedShowing(gameNotif)
                }
            }
    }
}
