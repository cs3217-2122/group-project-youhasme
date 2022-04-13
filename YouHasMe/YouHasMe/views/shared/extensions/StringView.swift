//
//  String.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 6/4/22.
//

import Foundation
import UIKit
extension String {
    func asImage() -> UIImage? {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.yellow,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)
        ]
        let textSize = self.size(withAttributes: attributes)

        UIGraphicsBeginImageContextWithOptions(textSize, true, 0)
        self.draw(at: CGPoint.zero, withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
