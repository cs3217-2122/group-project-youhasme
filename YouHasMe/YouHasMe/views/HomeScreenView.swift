//
//  HomeScreenView.swift
//  YouHasMe
//
//  Created by Neo Jing Xuan on 19/3/22.
//

import SwiftUI

struct HomeScreenView: View {
    var levelDesignerView: LevelDesignerView

    var body: some View {
        ZStack {

            VStack {
                NavigationView {
                    VStack {
                        Text("YOU HAS ME")
                            .font(.custom("Times New Roman", size: 100))

                        // TODO: implement start game view

                        NavigationLink("Design a Level", destination: levelDesignerView)
                            .font(.custom("Times New Roman", size: 30))
                    }.navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }

        }
    }
}
