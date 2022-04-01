//
//  AchievementView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 1/4/22.
//

import SwiftUI

struct AchievementView: View {
    @ObservedObject var achievementsViewModel: AchievementsViewModel
    var achievement: Achievement

    var body: some View {
        HStack {
            Image("baba")
                .resizable()
                .scaledToFit()
                .frame(width: CGFloat(achievementsViewModel.width),
                       height: CGFloat(achievementsViewModel.height))
            Text(achievement.name)
//                .opacity(achievement.isUnlocked ? 1.0 : 0.5)
        }
    }

}
