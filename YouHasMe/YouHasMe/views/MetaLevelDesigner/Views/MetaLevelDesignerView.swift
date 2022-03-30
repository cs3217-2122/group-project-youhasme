import SwiftUI

struct MetaLevelDesignerView: View {
    @ObservedObject var viewModel: MetaLevelDesignerViewModel
    var body: some View {
        ZStack {
            VStack {
                MetaLevelDesignerToolbarView(viewModel: viewModel.getToolbarViewModel())
                    .padding()
                MetaLevelDesignerPaletteView(viewModel: viewModel)
                    .padding()
                MetaLevelGridView(viewModel: viewModel)
                    .padding()
                Spacer()
                MetaLevelDesignerPersistenceView(viewModel: viewModel)
            }
            
            if let selectedTile = viewModel.selectedTile {
                NavigationFrame(backHandler: {
                    viewModel.deselectTile()
                }) {
                    MetaLevelDesignerTileInfoView(
                        viewModel: viewModel.getTileInfoViewModel(tile: selectedTile)
                    )
                }
            }
        }
    }
}

struct MetaLevelDesignerTileInfoView: View {
    @ObservedObject var viewModel: MetaLevelDesignerTileInfoViewModel
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(viewModel.metaEntities, id: \.self) { metaEntity in
                    HStack {
                        VStack {
                            Text(metaEntity.description)
                            MetaEntityView(viewModel: viewModel.getMetaEntityViewModel())
                        }
                        
                        if case .level(levelLoadable: _, unlockCondition: _) = metaEntity {
                            ConditionCreatorView()
                        }
                    }.frame(height: 100, alignment: .leading)
                }
            }
            
        }.frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .center
          )
          .background(Color.black.opacity(0.3))
    }
}

enum ConditionType: String {
    case metaLevel = "Meta Level"
    case level = "Level"
    case player = "Player"
    case numericLiteral = "Numeric"
    
    func getKeyPaths() -> [AnyNamedKeyPath] {
        switch self {
        case .metaLevel:
            return MetaLevel.typeErasedNamedKeyPaths
        case .level:
            return Level.typeErasedNamedKeyPaths
        case .player:
            return []
        case .numericLiteral:
            return []
        }
    }
}

extension ConditionType: CaseIterable {}
extension ConditionType: Identifiable {
    var id: String {
        rawValue
    }
    
    static func getEnum(by id: String) -> ConditionType? {
        ConditionType.allCases.first { $0.id == id }
    }
}
extension ConditionType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

enum ComparatorType: String {
    case eq = "="
    case geq = ">="
    case leq = "<="
    case lt = "<"
    case gt = ">"
}
extension ComparatorType: CaseIterable {}
extension ComparatorType: Identifiable {
    var id: String {
        rawValue
    }
    
    static func getEnum(by id: String) -> ComparatorType? {
        ComparatorType.allCases.first { $0.id == id }
    }
}
extension ComparatorType: CustomStringConvertible {
    var description: String {
        rawValue
    }
}

struct ConditionCreatorView: View {
    @State private var selectedSubjectConditionTypeId: String?
    @State private var selectedComparatorTypeId: String?
    @State private var selectedObjectConditionTypeId: String?

    var body: some View {
        HStack {
            VStack {
                List(ConditionType.allCases, selection: $selectedSubjectConditionTypeId) {
                    Text($0.description)
                }
                
                if let selectedSubjectConditionTypeId = selectedSubjectConditionTypeId,
                    let keyPaths = ConditionType.getEnum(by: selectedSubjectConditionTypeId)?.getKeyPaths() {
                    List(keyPaths) {
                        Text($0.description)
                    }
                }
            }
            
            List(ComparatorType.allCases, selection: $selectedComparatorTypeId) {
                Text($0.description)
            }
            
            VStack {
                List(ConditionType.allCases, selection: $selectedObjectConditionTypeId) {
                    Text($0.description)
                }
                
                if let selectedObjectConditionTypeId = selectedObjectConditionTypeId,
                   let keyPaths = ConditionType.getEnum(by: selectedObjectConditionTypeId)?.getKeyPaths() {
                    List(keyPaths) {
                        Text($0.description)
                    }
                }
            }
        }
    }
}

// struct MetaLevelDesignerView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetaLevelDesignerView().previewDevice(
//            PreviewDevice(rawValue: "iPad (9th generation")
//        )
//    }
// }
