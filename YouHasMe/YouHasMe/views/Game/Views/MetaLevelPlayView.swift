//
//  MetaLevelPlayView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 30/3/22.
//

import SwiftUI
import Combine

struct MetaLevelPlayView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelPlayViewModel
    
    let inverseDragThreshold: Double = 5.0.multiplicativeInverse()
    @State var lastDragLocation: CGPoint?

    var body: some View {
        ZStack {
            Group {
                MetaLevelGridView(viewModel: viewModel)
                Spacer()
                HStack(alignment: .center) {
                    ForEach(viewModel.contextualData) { data in
                        Button(data.description, action: data.action)
                    }
                }
            }
            
            if viewModel.overlayState != .off {
                NavigationFrame(
                    verticalAlignment: .center,
                    horizontalAlignment: .center,
                    backHandler: { viewModel.closeOverlay() }) {
                    Group {
                        switch viewModel.overlayState {
                        case .messages:
                            MessagesView(viewModel: viewModel.getMessagesViewModel())
                        case .travel:
                            TravelInfoView()
                        case .level:
                            LevelInfoView(viewModel: viewModel.getLevelInfoViewModel())
                        default:
                            Group {}
                        }
                    }
                }
            }
        }
    }
}

struct MessagesView: View {
    @ObservedObject var viewModel: MessagesViewModel
    
    var body: some View {
        ForEach(0..<viewModel.messages.count, id: \.self) { index in
            MessageView(message: viewModel.messages[index])
        }
    }
}

// https://getstream.io/blog/chat-app-swiftui-part1/
//struct MessageView: View {
//    let message: ChatMessage
//
//    var background: some View {
//        if (message.isSentByCurrentUser) {
//            return Color.blue.opacity(0.25)
//        } else {
//            return Color.gray.opacity(0.25)
//        }
//    }
//
//    var title: some View {
//        if message.isSentByCurrentUser {
//            return Text("")
//        } else {
//            return Text(message.author.id).font(.footnote)
//        }
//    }
//
//    var body: some View {
//        HStack {
//            if message.isSentByCurrentUser { Spacer() }
//            VStack(alignment: .leading) {
//                title
//                Text(message.text)
//                .padding(8)
//                .background(background)
//                .cornerRadius(24)
//            }
//            if !message.isSentByCurrentUser { Spacer() }
//        }.frame(maxWidth: .infinity)
//    }
//}

struct MessageView: View {
    @State var message: String
    
    var body: some View {
        Text(message)
            .padding(8)
            .background(Color.blue.opacity(0.25))
            .cornerRadius(24)
    }
}

struct LevelInfoView: View {
    @ObservedObject var viewModel: LevelInfoViewModel
    
    func getConditionStatusImage(_ condition: Condition) -> Image {
        condition.isConditionMet() ? Image.checkmark : Image.cross
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.levelInfo, id: \.self) { levelInfo in
                    Text(levelInfo.level.name)
                    
                    if let unlockCondition = levelInfo.unlockCondition {
                        getConditionStatusImage(unlockCondition)
                        Text(unlockCondition.description)
                    }
                    
                    if levelInfo.isLevelUnlocked {
                        Button("Enter Level") {
                            print("Entering Level")
                            // TODO
                        }
                    }
                }
            }
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
          )
          .background(Color.black.opacity(0.7))
    }
}

struct TravelInfoView: View {
    var body: some View {
        Text("travel")
    }
}

