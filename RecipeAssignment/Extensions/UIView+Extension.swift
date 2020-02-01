//
//  UIView+Extension.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit

//MARK:- Add Auto Dissmiss Keyboard on tap to this view
extension UIView {
    
    func setAutoDismissKeyboard() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        addGestureRecognizer(gesture)
    }
    
    @objc func dismissKeyboard() {
        endEditing(false)
    }
}
