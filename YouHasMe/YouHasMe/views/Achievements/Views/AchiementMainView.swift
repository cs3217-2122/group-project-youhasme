//
//  AchiementMainView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import SwiftUI

struct AchievementMainView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    @ObservedObject var notificationsViewModel: GameNotificationsViewModel

    var body: some View {
        ZStack {
        VStack(alignment: .leading) {
            Text("Achievements")
            List {
                if !achievementsViewModel.lockedAchievements.isEmpty {
                    Section(header: Text("Locked Achievements")) {
                        ForEach(achievementsViewModel.lockedAchievements) { achievement in
                            AchievementView(achievementsViewModel: achievementsViewModel,
                                            achievement: achievement)
                        }
                    }
                }

                if !achievementsViewModel.unlockedAchievements.isEmpty {
                    Section(header: Text("Unlocked Achievements")) {
                        ForEach(achievementsViewModel.unlockedAchievements) { achievement in
                            AchievementView(achievementsViewModel: achievementsViewModel,
                                            achievement: achievement)
                        }
                    }
                }
            }

            HStack {
                Button(action: {
                    gameState.state = .mainmenu
                }) {
                    Text("Back to Main Menu")
                }
                Spacer()
            }.padding()
        }

            GameNotificationsView(notificationsViewModel: notificationsViewModel)

        }.onAppear {
            achievementsViewModel.updateData()
        }
    }

}
