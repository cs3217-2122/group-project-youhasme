//
//  ConditionCreatorView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct ConditionEvaluableCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ConditionEvaluableCreatorViewModel
    func getTextColor(selected: Bool) -> Color {
        if (selected) {
            return Color.blue.opacity(1)
        } else {
            return Color.gray.opacity(0.8)
        }
    }
    
    var body: some View {
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
        if let selectedSubjectConditionTypeId = viewModel.selectedConditionTypeId,
            let keyPaths = ConditionType.getEnum(by: selectedSubjectConditionTypeId)?.getKeyPaths() {
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
        
        if let selectedConditionTypeId = viewModel.selectedConditionTypeId,
           let dependencies = ConditionType.getEnum(by: selectedConditionTypeId)?.getStorageDependencies() {
            NavigationView{
                List(dependencies, selection: $viewModel.selectedDependencyId) {
                    Text($0.name).foregroundColor(getTextColor(
                        selected: $0.id == viewModel.selectedDependencyId)
                    )
                }.navigationTitle("Dependency")
                .toolbar {
                    EditButton()
                }
            }.navigationViewStyle(.stack)
        }
        
        Button("Confirm") {
            viewModel.confirm()
        }
    }
}
