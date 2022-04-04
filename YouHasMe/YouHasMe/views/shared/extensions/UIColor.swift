//
//  UIColor.swift
//  YouHasMe
//
//  Created by Jia Cheng Sun on 3/4/22.
//

import Foundation
import UIKit
extension UIColor {
    func toImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
