//
//  DimensionSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 12/4/22.
//

import Foundation
import Combine

enum LevelTransitionStyle: String {
    case quadDirectional = "The Quad"
    case snakeLike = "Snakey Likey"
    
    func toGeneratorDecorators() -> [IdentityGeneratorDecorator.Type] {
        switch self {
        case .quadDirectional:
            return [
                QuadDirectionalGeneratorDecorator.self,
                QuadDirectionalLockGeneratorDecorator.self
            ]
        case .snakeLike:
            return [
                SnakeLikeConnectorGeneratorDecorator.self,
                SnakeLikeConnectorLockGeneratorDecorator.self
            ]
        }
    }
}
extension LevelTransitionStyle: CaseIterable {}
extension LevelTransitionStyle: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
extension LevelTransitionStyle: Identifiable {
    var id: Self {
        self
    }
}

enum RuleBlocks: String {
    case babaIsYou = "Baba Is You"
    case flagIsWin = "Flag Is Win"
    case rockIsStop = "Rock Is Stop"
    
    func toGeneratorDecorators() -> [IdentityGeneratorDecorator.Type] {
        switch self {
        case .babaIsYou:
            return [BabaIsYouGeneratorDecorator.self]
        case .flagIsWin:
            return [FlagIsWinGeneratorDecorator.self]
        case.rockIsStop:
            return [RockIsStopGeneratorDecorator.self]
        }
    }
}
extension RuleBlocks: CaseIterable {}
extension RuleBlocks: CustomStringConvertible {
    var description: String {
        rawValue
    }
}
extension RuleBlocks: Identifiable {
    var id: Self {
        self
    }
}

class DimensionSelectViewModel: ObservableObject {
    private var subscriptions: Set<AnyCancellable> = []
    @Published var widthSelection: Int = 0
    @Published var heightSelection: Int = 0
    let widthRange = 1..<6
    let heightRange = 1..<6
    @Published var dungeonName: String = ""
    @Published var levelTransitionStyle: LevelTransitionStyle = .snakeLike
    let levelTransitionStyles = LevelTransitionStyle.allCases
    @Published var initialRuleBlocks: Set<RuleBlocks> = []
    let ruleBlocks = RuleBlocks.allCases
    @Published var requiresOverwrite = false
    @Published var generatedPreview: [[Tile]]?
    
    var dungeonStorage = DungeonStorage()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest(self.$levelTransitionStyle, self.$initialRuleBlocks)
            .sink { [weak self] levelTransitionStyle, initialRuleBlocks in
                guard let self = self else {
                    return
                }
                self.generatedPreview = self.getPreviewLevel(
                    levelTransitionStyle: levelTransitionStyle,
                    initialRuleBlocks: initialRuleBlocks
                )
            }.store(in: &subscriptions)
    }
    
    func aboutToCreateLevel() {
        if dungeonStorage.existsDungeon(name: dungeonName) {
            requiresOverwrite = true
        }
    }
    
    func getDimensions() -> Rectangle {
        Rectangle(
            width: widthRange.index(widthRange.startIndex, offsetBy: widthSelection),
            height: heightRange.index(heightRange.startIndex, offsetBy: heightSelection)
        )
    }
    
    func getGenerators(
        levelTransitionStyle: LevelTransitionStyle,
        initialRuleBlocks: Set<RuleBlocks>
    ) -> [IdentityGeneratorDecorator.Type] {
        var generators: [IdentityGeneratorDecorator.Type] = [CompletelyEnclosedGeneratorDecorator.self]
        generators.append(contentsOf: levelTransitionStyle.toGeneratorDecorators())
        generators.append(contentsOf: initialRuleBlocks.flatMap {
            $0.toGeneratorDecorators()
        })
        return generators
    }

    func getDungeon() -> DesignableDungeon {
        do {
            try dungeonStorage.deleteDungeon(name: dungeonName)
        } catch {
            globalLogger.error("Failed to delete dungeon")
        }

        let dimensions = getDimensions()
        let generators = getGenerators(levelTransitionStyle: levelTransitionStyle, initialRuleBlocks: initialRuleBlocks)
        
        return .newDungeon(
            DungeonParams(
                name: dungeonName,
                dimensions: dimensions,
                generators: generators
            )
        )
    }
    
    func getPreviewLevel(
        levelTransitionStyle: LevelTransitionStyle,
        initialRuleBlocks: Set<RuleBlocks>
    ) -> [[Tile]] {
        let generator = BaseGenerator().decorateWithAll(
            getGenerators(levelTransitionStyle: levelTransitionStyle,
            initialRuleBlocks: initialRuleBlocks))
        return generator.generate(
            dimensions: Dungeon.defaultLevelDimensions,
            levelPosition: Point(x: 1, y: 1), // We are generating a preview of a non-boundary level
            extremities: Rectangle(width: 6, height: 6)
        )
    }
    
    func getTileViewModel(at position: Point) -> EntityViewModel {
        guard let generatedPreview = generatedPreview else {
            return EntityViewModel(tile: nil, status: nil)
        }
        let tile = generatedPreview[position]
        return EntityViewModel(tile: tile, status: nil)
    }
}
