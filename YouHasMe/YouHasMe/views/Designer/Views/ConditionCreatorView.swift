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
                .navigationTitle("Condition Type")
                .toolbar {
                    EditButton()
                }
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
                        }.navigationTitle("Field")
                        .toolbar {
                            EditButton()
                        }
                    }.navigationViewStyle(.stack)
                }
                
                if conditionType == .level {
                    NavigationView{
                        List(viewModel.levelMetadata, selection: $viewModel.selectedIdentifier) {
                            Text($0.name).foregroundColor(getTextColor(
                                selected: $0.id == viewModel.selectedIdentifier)
                            )
                        }.navigationTitle("Level Dependency")
                        .toolbar {
                            EditButton()
                        }
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
