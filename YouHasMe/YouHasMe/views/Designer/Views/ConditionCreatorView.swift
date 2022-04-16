//
//  ConditionCreatorView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI
import Combine

struct ConditionEvaluableCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConditionEvaluableCreatorViewModel
    @State var isShowingFailureAlert: Bool = false
    @State var isShowingSuccessAlert: Bool = false
    @State var alertMessage: String = ""
    func getTextColor(selected: Bool) -> Color {
        if (selected) {
            return Color.blue.opacity(1)
        } else {
            return Color.gray.opacity(0.8)
        }
    }
    
    var body: some View {
        Group {
            NavigationView {
                List(ConditionType.allCases, selection: $viewModel.selectedConditionTypeId) {
                    Text($0.description)
                        .foregroundColor(getTextColor(
                            selected: $0.id == viewModel.selectedConditionTypeId)
                        )
                }
                .environment(\.editMode, Binding.constant(EditMode.active))
                .navigationTitle("Condition Type")
            }.navigationViewStyle(.stack)
            
            if let selectedConditionTypeId = viewModel.selectedConditionTypeId,
               let conditionType = ConditionType.getEnum(by: selectedConditionTypeId) {
                
                if conditionType == .numericLiteral {
                    NavigationView{
                        Group {
                            // reference: https://stackoverflow.com/questions/58733003/how-to-create-textfield-that-only-accepts-numbers
                            TextField("Number", text: $viewModel.numericLiteral)
                                .keyboardType(.numberPad)
                                .onReceive(Just(viewModel.numericLiteral)) { newValue in
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        viewModel.numericLiteral = filtered
                                    }
                                }
                        }.navigationTitle("Pick a Number")
                    }.navigationViewStyle(.stack)
                }
                
                if let keyPaths = conditionType.getKeyPaths() {
                    NavigationView{
                        List(keyPaths, selection: $viewModel.selectedFieldId) {
                            Text($0.description).foregroundColor(getTextColor(
                                selected: $0.id == viewModel.selectedFieldId)
                            )
                        }
                        .environment(\.editMode, Binding.constant(EditMode.active))
                        .navigationTitle("Property to Query")
                        
                    }.navigationViewStyle(.stack)
                }
                
                if conditionType == .level {
                    NavigationView{
                        List(viewModel.levelMetadata, selection: $viewModel.selectedIdentifier) { (metaData: LevelMetadata) in
                            Text("Id: \(metaData.id.description)\nName: \(metaData.name)")
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(getTextColor(
                                    selected: metaData.id == viewModel.selectedIdentifier)
                                )
                        }
                        .environment(\.editMode, Binding.constant(EditMode.active))
                        .navigationTitle("Level Dependency")
                    }.navigationViewStyle(.stack)
                }
            }
            
            Button("Confirm") {
                let result = viewModel.confirm()
                switch result {
                case .success(let evaluable):
                    alertMessage = evaluable.description
                    isShowingSuccessAlert = true
                case .failure(let error):
                    alertMessage = error.rawValue
                    isShowingFailureAlert = true
                }
            }
            
            Button("Close") {
                viewModel.finish()
                dismiss()
            }
        }
        .alert(alertMessage, isPresented: $isShowingFailureAlert) {
            Button("Ok", role: .cancel) {}
        }.alert(alertMessage, isPresented: $isShowingSuccessAlert) {
            Button("Ok", role: .cancel) {}
        }
    }
}
