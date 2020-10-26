//
//  ButtonExt.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/25/20.
//

import Foundation
import UIKit

extension UIButton {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(x: self.bounds.origin.x - 15, y: self.bounds.origin.y - 15, width: self.bounds.size.width + 30, height: self.bounds.size.height + 30);
        return newArea.contains(point);
    }
}
