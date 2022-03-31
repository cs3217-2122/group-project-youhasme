//
//  MetaLevelSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import Foundation
import Combine

struct URLListObject {
    var url: URL
    var name: String
}

extension URLListObject: Hashable {}

class MetaLevelSelectViewModel: ObservableObject {
    var roomStorage = FirebaseRoomStorage()
    var metaLevelStorage = MetaLevelStorage()
    var onlineLevelStorage = FirebaseMetaLevelStorage()
    @Published var onlineMetaLevels: [OnlineMetaLevel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        onlineLevelStorage.$metaLevels
            .assign(to: \.onlineMetaLevels, on: self)
            .store(in: &cancellables)
    }
    
    func getAllMetaLevels() -> [URLListObject] {
        let (urls, filenames) = metaLevelStorage.getAllFiles()
        return zip(urls, filenames).map { URLListObject(url: $0, name: $1) }
    }
    
    func uploadMetaLevel(urlListObject: URLListObject) {
        guard let currMetaLevel: MetaLevel = metaLevelStorage.loadMetaLevel(name: urlListObject.name) else {
            fatalError("should not be nil")
        }
        onlineLevelStorage.upload(metaLevel: currMetaLevel)
    }
    
    func createRoom(onlineMetaLevel: OnlineMetaLevel) {
        roomStorage.createRoom(from: onlineMetaLevel)
    }
}
