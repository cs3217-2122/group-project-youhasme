//
//  ConditionCreatorView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 2/4/22.
//

import SwiftUI

struct ConditionCreatorView: View {
    @ObservedObject var viewModel: ConditionCreatorViewModel
    @State private var editingSubjectConditionType: Bool = false
    @State private var editingComparatorType: Bool = false
    @State private var editingObjectConditionType: Bool = false
    

    func getTextColor(selected: Bool) -> Color {
        if (selected) {
            return Color.blue.opacity(1)
        } else {
            return Color.gray.opacity(0.8)
        }
    }
    
    var body: some View {
        VStack {
            Group {
                Button("Subject Condition") {
                    editingSubjectConditionType.toggle()
                }
                Text(viewModel.tempSubjectRepresentation)
            }
            
            Group {
                Button("Comparator") {
                    editingComparatorType.toggle()
                }
                if let selectedComparatorTypeId = viewModel.selectedComparatorTypeId {
                    Text(selectedComparatorTypeId)
                }
            }
            
            Group {
                Button("Object Condition") {
                    editingObjectConditionType.toggle()
                }
                Text(viewModel.tempObjectRepresentation)
            }
            
            Button("Save Condition") {
                viewModel.saveCondition()
            }
        }
        .fullScreenCover(isPresented: $editingSubjectConditionType) {
            ConditionEvaluableCreatorView(
                selectedConditionTypeId: $viewModel.selectedSubjectConditionTypeId,
                selectedFieldId: $viewModel.selectedSubjectField,
                selectedDependencyId: $viewModel.selectedSubjectDependency
            )
            
        }
        .fullScreenCover(isPresented: $editingComparatorType) {
            ConditionComparatorCreatorView(
                selectedComparatorTypeId: $viewModel.selectedComparatorTypeId
            )
        }
        .fullScreenCover(isPresented: $editingObjectConditionType) {
            ConditionEvaluableCreatorView(
                selectedConditionTypeId: $viewModel.selectedObjectConditionTypeId,
                selectedFieldId: $viewModel.selectedObjectField,
                selectedDependencyId: $viewModel.selectedObjectDependency
            )
        }
    }
}

struct ConditionComparatorCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedComparatorTypeId: String?
    
    func getTextColor(selected: Bool) -> Color {
        if (selected) {
            return Color.blue.opacity(1)
        } else {
            return Color.gray.opacity(0.8)
        }
    }
    
    var body: some View {
        NavigationView {
            List(ComparatorType.allCases, selection: $selectedComparatorTypeId) {
                Text($0.description).foregroundColor(getTextColor(
                    selected: $0.id == selectedComparatorTypeId)
                )
            }.navigationTitle("Comparator")
            .toolbar {
                EditButton()
            }
        }.navigationViewStyle(.stack)
        Button("Close") {
            dismiss()
        }
    }
}

struct ConditionEvaluableCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedConditionTypeId: String?
    @Binding var selectedFieldId: String?
    @Binding var selectedDependencyId: String?
    
    func getTextColor(selected: Bool) -> Color {
        if (selected) {
            return Color.blue.opacity(1)
        } else {
            return Color.gray.opacity(0.8)
        }
    }
    
    var body: some View {
        NavigationView {
            List(ConditionType.allCases, selection: $selectedConditionTypeId) {
                Text($0.description)
                    .foregroundColor(getTextColor(
                        selected: $0.id == selectedConditionTypeId)
                    )
            }
            .navigationTitle("Condition Type")
            .toolbar {
                EditButton()
            }
        }.navigationViewStyle(.stack)
        if let selectedSubjectConditionTypeId = selectedConditionTypeId,
            let keyPaths = ConditionType.getEnum(by: selectedSubjectConditionTypeId)?.getKeyPaths() {
            NavigationView{
                List(keyPaths, selection: $selectedFieldId) {
                    Text($0.description).foregroundColor(getTextColor(
                        selected: $0.id == selectedFieldId)
                    )
                }.navigationTitle("Field")
                .toolbar {
                    EditButton()
                }
            }.navigationViewStyle(.stack)
        }
        
        if let selectedConditionTypeId = selectedConditionTypeId,
           let dependencies = ConditionType.getEnum(by: selectedConditionTypeId)?.getStorageDependencies() {
            NavigationView{
                List(dependencies, selection: $selectedDependencyId) {
                    Text($0.name).foregroundColor(getTextColor(
                        selected: $0.id == selectedDependencyId)
                    )
                }.navigationTitle("Dependency")
                .toolbar {
                    EditButton()
                }
            }.navigationViewStyle(.stack)
        }
        
        Button("Close") {
            dismiss()
        }
    }
}
