//
//  ViewControllerExt.swift
//  Gameology
//
//  Created by Kyle Gardner on 10/25/20.
//

import Foundation
import UIKit

extension UIViewController {
    func animateIn(view: UIView) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {view.alpha = 1})
    }
    
    func animateOut(view: UIView) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {view.alpha = 0})
    }
}
