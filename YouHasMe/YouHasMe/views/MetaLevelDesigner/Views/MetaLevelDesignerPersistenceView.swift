//
//  MetaLevelDesignerPersistenceView.swift
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

struct MetaLevelDesignerPersistenceView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    
    @State var showSaveLevelAlert = false
    @State var saveMessage = ""
    var saveErrorMessage = "Save Error"
    @State var showSaveErrorAlert = false
    @State var loadSuccess = false
    @State var showMetaLevelNameAlert = false
    @State var metaLevelButtonText: String = ""
    @State var unconfirmedMetaLevelName = ""

    var body: some View {
        HStack {
            Button("Load") {
                gameState.state = .selectingMeta
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

            MetaLevelNameButton(viewModel: viewModel.getNameButtonViewModel()) {
                unconfirmedMetaLevelName = viewModel.currMetaLevel.name
                showMetaLevelNameAlert = true
            }
            
            Spacer()
            
            Button("Play") {
                do {
                    try viewModel.save()
                    gameState.stateStack.append(
                        .playingMeta(playableMetaLevel: viewModel.getPlayableMetaLevel())
                    )
                } catch {
                    showSaveErrorAlert = true
                }
            }
        }
        .padding([.leading, .trailing], 10.0)
        .textFieldAlert(isShowing: $showMetaLevelNameAlert, text: $unconfirmedMetaLevelName, title: "Change name")
        .onChange(of: showMetaLevelNameAlert) { isShowing in
            guard !isShowing else {
                return
            }
            viewModel.currMetaLevel.renameLevel(to: unconfirmedMetaLevelName)
            showMetaLevelNameAlert = false
        }
    }
}
import Combine
class MetaLevelNameButtonViewModel: ObservableObject {
    @Published var name: String = ""
    private var subscriptions: Set<AnyCancellable> = []
    init(namePublisher: AnyPublisher<String, Never>) {
        namePublisher
            .sink { [weak self] name in self?.name = name }
            .store(in: &subscriptions)
    }
}

struct MetaLevelNameButton: View {
    @ObservedObject var viewModel: MetaLevelNameButtonViewModel
    let onTapHandler: () -> Void
    
    var body: some View {
        Button(viewModel.name, action: onTapHandler)
    }
}

struct MetaLevelDesignerPersistenceView_Previews: PreviewProvider {
    static var previews: some View {
        MetaLevelDesignerPersistenceView(
            viewModel: MetaLevelDesignerViewModel()
        )
    }
}
