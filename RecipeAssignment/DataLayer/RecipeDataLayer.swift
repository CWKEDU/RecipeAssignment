//
//  RecipeDataLayer.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit


//MARK:- RecipeDataLayerDelegate
protocol RecipeDataLayerDelegate : NSObject {
    //update delegate that recipes have changed
    func recipesChanges(recipes : [Recipe])
    func recipeTypeChanges(recipeTypes : [String])
}



class RecipeDataLayer {
    //make singleton for this layer
    static let shared = RecipeDataLayer()
    
    //MARK:- Vars
    private var recipeTypes : [String] = [] {
        didSet {
            self.delegate?.recipeTypeChanges(recipeTypes: recipeTypes)
        }
    }
    private var recipes : [Recipe] = [] {
        didSet{
            //inform delegate of state change
            self.delegate?.recipesChanges(recipes: recipes)
        }
    }
    weak var delegate : RecipeDataLayerDelegate? = nil {
        didSet{
            //immediately report back the current state
            self.delegate?.recipesChanges(recipes: self.recipes)
            self.delegate?.recipeTypeChanges(recipeTypes: self.recipeTypes)
        }
    }
    
    
    //MARK: - Inits
    private init() {
        setupRecipeTypes()
    }
    
}



//MARK:- Main Call Funcs
extension RecipeDataLayer {
    
    func getRecipeTypes() -> [String] {
        return recipeTypes
    }
    
    func getRecipes() -> [Recipe] {
        return recipes
    }
    
}




//MARK:- Private Helper Funcs
private extension RecipeDataLayer {
    func setupRecipeTypes() {
            DispatchQueue.global().async {
                do{
                    self.recipeTypes = try ParseUtil().getRecipeTypes()
    //                print("RecipeTypes: \(self.recipeTypes)")
                    self.hardCodeRecipe()
                } catch ParseUtilErr.parseFailed(let err){
                    print(err)
                } catch {
                    print("Unhandled Error: \(error.localizedDescription)")
                }
            }
        }
    
    
    
    func hardCodeRecipe() {
        //hard code recipe, 1 recipe for each type
        recipes = recipeTypes.map { (type) -> Recipe in
            let randNum = Int.random(in: 0 ..< 4)
            let imageName = String(format: SampleImageNameFormat.name, randNum + 1)
            guard let image = UIImage(named: imageName) else {
                fatalError("Hard code image not found")
            }
            let ingredients = ["Ingredient A", "Ingredient B", "Ingredient C"]
            let steps = ["Step 1", "Step 2", "Step 3"]
            
            return Recipe(recipeName: "Recipe \(randNum)", recipeType: type, picture: image, ingredients: ingredients, steps: steps)
        }
//        print("recipes: \(recipes)")
    }
}
