//
//  GameNotificationView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 8/4/22.
//
//  Reference: https://prafullkumar77.medium.com/swiftui-how-to-make-toast-and-notification-banners-bc8aae313b33

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
                .background(.black)
                .cornerRadius(8)
                Spacer()
        }
            .padding()
            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
            .onTapGesture {
                withAnimation {
                    gameNotifsViewModel.hasFinishedShowing(gameNotif)
                }
            }
    }
}
