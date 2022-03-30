//
//  MetaLevelSelectViewModel.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 26/3/22.
//

import Foundation

class MetaLevelSelectViewModel: ObservableObject {
    var metaLevelStorage = MetaLevelStorage()

    func getAllMetaLevels() -> [Loadable] {
        let (urls, filenames) = metaLevelStorage.getAllFiles()
        return zip(urls, filenames).map { Loadable(url: $0, name: $1) }
    }
}
