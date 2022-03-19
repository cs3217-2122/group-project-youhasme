//
//  ContentView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/3/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeScreenView(levelDesignerView:
                        LevelDesignerView())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
