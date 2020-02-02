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
    private lazy var fileUtil : FileUtility = FileUtility()
    
    
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
    
    func getRecipeImage(imagePath : String) throws -> UIImage {
        let imgData = try fileUtil.readData(filePath: imagePath)
        guard let img = UIImage(data: imgData) else {
            throw NSError(domain: "Fail data to image", code: 0, userInfo: nil)
        }
        return img
    }
    
    //convert and save
    func saveRecipe(name: String, type: String, image: UIImage, ingredients: String, steps: String) {
     
        do{
            let imagePath = try saveImage(name: name, image: image)
            let recipe = Recipe(recipeName: name, recipeType: type, picturePath: imagePath, ingredients: ingredients, steps: steps)
            
            //add to realm
            
            
            recipes.append(recipe)
            
            
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
    }
    
    
    
    //convert and save
    func updateRecipe(oldRecipe : Recipe, name: String, type: String, image: UIImage, ingredients: String, steps: String) {
     
        do{
            //find and replace the old recipe
            guard let oldIndex = recipes.firstIndex(where: { $0 == oldRecipe }) else {
                throw NSError(domain: "Old recipe not found", code: 0, userInfo: nil)
            }
            
            let imgPath = try saveImage(name: name, image: image)
            let recipe = Recipe(recipeName: name, recipeType: type, picturePath: imgPath, ingredients: ingredients, steps: steps)
            
            //remove old image
            try fileUtil.deleteFile(filePath: oldRecipe.picturePath)
            
            //update recipe
            recipes[oldIndex] = recipe
            
            //update recipe to realm
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
    }
    
    
    
    func deleteRecipe(oldRecipe : Recipe) {
        do{
            //find and replace the old recipe
            guard let oldIndex = recipes.firstIndex(where: { $0 == oldRecipe }) else {
                throw NSError(domain: "Old recipe not found", code: 0, userInfo: nil)
            }
            
            //remove old image
            try fileUtil.deleteFile(filePath: oldRecipe.picturePath)
            
            //remove recipe
            recipes.remove(at: oldIndex)
            
            //update recipe to realm
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
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
            let ingredients =
            """
            Sample Ingredient A
            Sample Ingredient B
            Sample Ingredient C
            """
            let steps =
            """
            Sample Step 1
            Sample Step 2
            Sample Step 3
            """
            
            do{
                let imgPath = try saveImage(name: imageName, image: image)
                return Recipe(recipeName: "Recipe \(randNum)", recipeType: type, picturePath: imgPath, ingredients: ingredients, steps: steps)
            }catch{
                fatalError("Fail save image: \(error.localizedDescription)")
            }
        }
    }
    
    
    
    func saveImage(name : String, image : UIImage) throws -> String {
        guard let imgData = image.jpegData(compressionQuality: 1) else {
            throw NSError(domain: "Fail compress image", code: 0, userInfo: nil)
        }
        return try fileUtil.writeData(fileName: name, imageData: imgData)
    }
}



