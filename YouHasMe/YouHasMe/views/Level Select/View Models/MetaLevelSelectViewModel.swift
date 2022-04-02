//
//  MetaLevelSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import Foundation

struct URLListObject {
    var url: URL
    var name: String
}

extension URLListObject: Hashable {}

class MetaLevelSelectViewModel: ObservableObject {
    var metaLevelStorage = MetaLevelStorage()

    func getAllMetaLevels() -> [URLListObject] {
        let (urls, filenames) = metaLevelStorage.getAllFiles()
        return zip(urls, filenames).map { URLListObject(url: $0, name: $1) }
    }
}
