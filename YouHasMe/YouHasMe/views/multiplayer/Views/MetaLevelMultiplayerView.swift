//
//  MetaLevelMultiplayerView.swift
//  YouHasMe
//
//  Created by Dhruv Shah on 31/3/22.
//

import SwiftUI

struct MetaLevelMultiplayerView: View {
    @ObservedObject var viewModel: MetaLevelMultiplayerViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MetaLevelMultiplayerView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelMultiplayerView(viewModel: MetaLevelMultiplayerViewModel())
    }
}
