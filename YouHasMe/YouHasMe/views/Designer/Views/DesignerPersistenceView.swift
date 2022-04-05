//
//  DungeonDesignerPersistenceView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 25/3/22.
//

import SwiftUI

struct TextFieldAlert<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    @Binding var text: String
    let presenting: () -> Presenting
    let title: String

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting()
                    .blur(radius: self.isShowing ? 2 : 0)
                    .disabled(self.isShowing)
                VStack {
                    Text(self.title)
                    TextField(self.title, text: self.$text)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                            }
                        }) {
                            Text("Dismiss")
                        }
                    }
                }
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}

extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: String) -> some View {
        
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: { self },
                       title: title)
    }

}

struct DesignerPersistenceView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: DesignerViewModel
    
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    var saveErrorMessage = "Save Error"
    @State var showSaveErrorAlert = false
    @State var loadSuccess = false
    @State var showMetaLevelNameAlert = false
    @State var dungeonButtonText: String = ""
    @State var unconfirmedDungeonName = ""

    var body: some View {
        HStack {
            Button("Load") {
                gameState.state = .selecting
            }

            Button("Save") {
                do {
                    try viewModel.save()
                } catch {
                    showSaveErrorAlert = true
                }
            }.alert(isPresented: $showSaveLevelAlert) {
                Alert(title: Text(saveMessage), dismissButton: .cancel(Text("close")))
            }.alert(isPresented: $showSaveErrorAlert) {
                Alert(title: Text(saveErrorMessage), dismissButton: .cancel(Text("close")))
            }

            DungeonNameButton(viewModel: viewModel.getNameButtonViewModel()) {
                unconfirmedDungeonName = viewModel.dungeon.name
                showMetaLevelNameAlert = true
            }
            
            Spacer()
            
            Button("Play") {
                do {
                    try viewModel.save()
                    gameState.stateStack.append(
                        .playing(playableDungeon: viewModel.getPlayableDungeon())
                    )
                } catch {
                    showSaveErrorAlert = true
                }
            }
        }
        .padding([.leading, .trailing], 10.0)
        .textFieldAlert(isShowing: $showMetaLevelNameAlert, text: $unconfirmedDungeonName, title: "Change name")
        .onChange(of: showMetaLevelNameAlert) { isShowing in
            guard !isShowing else {
                return
            }
            viewModel.dungeon.renameLevel(to: unconfirmedDungeonName)
            showMetaLevelNameAlert = false
        }
    }
}
import Combine
class DungeonNameButtonViewModel: ObservableObject {
    @Published var name: String = ""
    private var subscriptions: Set<AnyCancellable> = []
    init(namePublisher: AnyPublisher<String, Never>) {
        namePublisher
            .sink { [weak self] name in self?.name = name }
            .store(in: &subscriptions)
    }
}

struct DungeonNameButton: View {
    @ObservedObject var viewModel: DungeonNameButtonViewModel
    let onTapHandler: () -> Void
    
    var body: some View {
        Button(viewModel.name, action: onTapHandler)
    }
}
