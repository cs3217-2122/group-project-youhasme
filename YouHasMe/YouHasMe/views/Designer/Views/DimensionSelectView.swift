//
//  DimensionSelectView.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 9/4/22.
//

import SwiftUI

struct DimensionSelectView: View {
    @EnvironmentObject var gameState: GameState
    @ObservedObject var viewModel: DimensionSelectViewModel
    var body: some View {
        HStack{
            ScrollView {
            VStack {
                Group {
                    Text("Dungeon Height").font(.title3)
                    Picker("Dungeon Height", selection: $viewModel.heightSelection) {
                        ForEach(viewModel.heightRange) {
                            Text("\($0) levels high")
                        }
                    }.padding()
                }
                Group {
                    Text("Dungeon Width").font(.title3)
                    Picker("Dungeon Width", selection: $viewModel.widthSelection) {
                        ForEach(viewModel.widthRange) {
                            Text("\($0) levels wide")
                        }
                    }.padding()
                }
                Group {
                    Text("Dungeon name").font(.title3)
                    TextField("Dungeon name", text: $viewModel.dungeonName)
                        .padding()
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.center)
                }
                Group {
                    Text("Level Transition Style").font(.title3)
                    Picker("Level Transition Style", selection: $viewModel.levelTransitionStyle) {
                        ForEach(viewModel.levelTransitionStyles) {
                            Text($0.description)
                        }
                    }
                }
                Group {
                    Text("Initial Rule Blocks").font(.title3)
                    List(viewModel.ruleBlocks, selection: $viewModel.initialRuleBlocks) { (ruleBlock: RuleBlocks) in
                        Text(ruleBlock.description)
                    }
                    .frame(minHeight: CGFloat(viewModel.ruleBlocks.count * 45))
                    .listStyle(.plain)
                    .environment(\.editMode, Binding.constant(EditMode.active))
                }
                
                GeometryReader { proxy in
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            let gridViewData = GridViewData(
                                proxy: proxy,
                                displayMode: .fixedDimensionsInCells(
                                    dimensions: Dungeon.defaultLevelDimensions
                                )
                            )
                            ForEach(0..<gridViewData.heightInCells, id: \.self) { y in
                                HStack(spacing: 0) {
                                    ForEach(0..<gridViewData.widthInCells, id: \.self) { x in
                                        EntityView(
                                            viewModel: viewModel.getTileViewModel(at: Point(x: x, y: y))
                                        )
                                        .frame(width: gridViewData.cellWidth, height: gridViewData.cellHeight)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }.frame(minWidth: 400, minHeight: 400)
                
                Button("Confirm") {
                    guard !viewModel.dungeonName.isEmpty else {
                        return
                    }
                    
                    viewModel.aboutToCreateLevel()
                    
                    if !viewModel.requiresOverwrite {
                        gameState.state = .designing(designableDungeon: viewModel.getDungeon())
                    }
                }.padding()
                
                Button("Cancel") {
                    gameState.state = .mainmenu
                }
            }
            .alert("Dungeon Already Exists", isPresented: $viewModel.requiresOverwrite) {
                Button(role: .destructive) {
                    gameState.state = .designing(designableDungeon: viewModel.getDungeon())
                } label: {
                    Text("Overwrite")
                }
            } message: {
                Text("There is already a dungeon with this name, are you sure you wish to replace it?")
            }
        }
        }
    }
}
