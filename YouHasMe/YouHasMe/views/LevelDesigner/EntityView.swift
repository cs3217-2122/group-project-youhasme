//
//  EntityView.swift
//  YouHasMe
//

import SwiftUI

struct EntityView: View {
    let entityType: EntityType?
    var body: some View {
        if let entityType = entityType {
            Image(entityTypeToImageString(type: entityType))
                .resizable()
                .scaledToFit()
        } else {
            SwiftUI.Rectangle()
                .fill(.gray)
        }
    }
}

// struct EntityView_Previews: PreviewProvider {
//    static var previews: some View {
//        EntityView()
//    }
// }
