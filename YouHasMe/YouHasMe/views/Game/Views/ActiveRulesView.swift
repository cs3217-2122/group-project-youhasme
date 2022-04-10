//
//  ActiveRulesView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 10/4/22.
//

import SwiftUI

struct ActiveRulesView: View {
    @ObservedObject var viewModel: ActiveRulesViewModel
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.activeRules, id: \.self) { rule in
                    Text(rule.debugDescription)
                }
            }
        }.frame(maxHeight: 100)
    }
}
