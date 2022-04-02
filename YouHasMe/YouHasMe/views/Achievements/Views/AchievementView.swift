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
                .frame(width: CGFloat(achievementsViewModel.imageWidth),
                       height: CGFloat(achievementsViewModel.imageHeight))
            VStack(alignment: .leading) {
                Text(achievement.name)
                Text(achievement.description).font(.caption)
            }.padding(.leading)
        }
    }

}
