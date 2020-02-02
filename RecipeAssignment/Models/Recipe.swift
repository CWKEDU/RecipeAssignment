//
//  Recipe.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit
import RealmSwift

class Recipe : Object {
    @objc dynamic var recipeName : String = ""
    @objc dynamic var recipeType : String = ""
    @objc dynamic var picturePath : String = ""
    @objc dynamic var ingredients : String = ""
    @objc dynamic var steps : String = ""
    
    convenience init(name : String, type : String, picPath : String, ingredients : String, steps : String) {
        self.init()
        self.recipeName = name
        self.recipeType = type
        self.picturePath = picPath
        self.ingredients = ingredients
        self.steps = steps
    }
    
}
