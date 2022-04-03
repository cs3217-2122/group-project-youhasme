//
//  MessageView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import SwiftUI
struct MessagesView: View {
    @ObservedObject var viewModel: MessagesViewModel
    
    var body: some View {
        ForEach(0..<viewModel.messages.count, id: \.self) { index in
            MessageView(message: viewModel.messages[index])
        }
    }
}

struct MessageView: View {
    @State var message: String
    
    var body: some View {
        Text(message)
            .padding(8)
            .background(Color.blue.opacity(0.25))
            .cornerRadius(24)
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
