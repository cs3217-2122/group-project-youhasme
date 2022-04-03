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
        .popover(isPresented: $editingSubjectConditionType) {
            NavigationView {
                List(ConditionType.allCases, selection: $viewModel.selectedSubjectConditionTypeId) {
                    Text($0.description)
                        .foregroundColor(getTextColor(
                            selected: $0.id == viewModel.selectedSubjectConditionTypeId)
                        )
                }
                .navigationTitle("Condition Type")
                .toolbar {
                    EditButton()
                }
            }
            if let selectedSubjectConditionTypeId = viewModel.selectedSubjectConditionTypeId,
                let keyPaths = ConditionType.getEnum(by: selectedSubjectConditionTypeId)?.getKeyPaths() {
                NavigationView{
                    List(keyPaths, selection: $viewModel.selectedSubjectField) {
                        Text($0.description).foregroundColor(getTextColor(
                            selected: $0.id == viewModel.selectedSubjectField)
                        )
                    }.navigationTitle("Field")
                    .toolbar {
                        EditButton()
                    }
                }
            }
            
            if let selectedSubjectConditionTypeId = viewModel.selectedSubjectConditionTypeId,
               let dependencies = ConditionType.getEnum(by: selectedSubjectConditionTypeId)?.getStorageDependencies() {
                NavigationView{
                    List(dependencies, selection: $viewModel.selectedSubjectDependency) {
                        Text($0.name).foregroundColor(getTextColor(
                            selected: $0.id == viewModel.selectedSubjectDependency)
                        )
                    }.navigationTitle("Dependency")
                    .toolbar {
                        EditButton()
                    }
                }
            }
            
        }.popover(isPresented: $editingComparatorType) {
            NavigationView {
                List(ComparatorType.allCases, selection: $viewModel.selectedComparatorTypeId) {
                    Text($0.description).foregroundColor(getTextColor(
                        selected: $0.id == viewModel.selectedComparatorTypeId)
                    )
                }.navigationTitle("Comparator")
                .toolbar {
                    EditButton()
                }
            }
        }
        .popover(isPresented: $editingObjectConditionType) {
            NavigationView {
                List(ConditionType.allCases, selection: $viewModel.selectedObjectConditionTypeId) {
                    Text($0.description).foregroundColor(getTextColor(
                        selected: $0.id == viewModel.selectedObjectConditionTypeId)
                    )
                }.navigationTitle("Condition Type")
                .toolbar {
                    EditButton()
                }
            }
                
                if let selectedObjectConditionTypeId = viewModel.selectedObjectConditionTypeId,
                   let keyPaths = ConditionType.getEnum(by: selectedObjectConditionTypeId)?.getKeyPaths() {
                    NavigationView {
                    List(keyPaths, selection: $viewModel.selectedObjectField) {
                        Text($0.description).foregroundColor(getTextColor(
                            selected: $0.id == viewModel.selectedObjectField)
                        )
                    }.navigationTitle("Field")
                        .toolbar {
                            EditButton()
                        }
                    }
                }
                
                if let selectedObjectConditionTypeId = viewModel.selectedObjectConditionTypeId,
                   let dependencies = ConditionType.getEnum(by: selectedObjectConditionTypeId)?.getStorageDependencies() {
                    NavigationView{
                        List(dependencies, selection: $viewModel.selectedObjectDependency) {
                            Text($0.name).foregroundColor(getTextColor(
                                selected: $0.id == viewModel.selectedObjectDependency)
                            )
                        }.navigationTitle("Dependency")
                        .toolbar {
                            EditButton()
                        }
                    }
                }
            }
        
    }
}
