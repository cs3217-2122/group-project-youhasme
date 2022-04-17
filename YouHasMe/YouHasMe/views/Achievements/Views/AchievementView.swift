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
            Image(AchievementImages.getAchievementImageString(achievement: achievement))
                .resizable()
                .frame(width: CGFloat(ViewConstants.achievementImageWidth),
                       height: CGFloat(ViewConstants.achievementImageHeight))
                .opacity(achievement.isUnlocked ? 1.0 : 0.5)
            VStack(alignment: .leading) {
                Text(achievement.name)
                Text(achievement.shouldHide ? "???" : achievement.description).font(.caption)
            }.padding(.leading)
        }
    }

}
