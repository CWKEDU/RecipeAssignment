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
    
    //event
    func readRecipeResult(recipes : [Recipe], err : RecipeDataLayerErr?)
    func addRecipeResult(recipe : Recipe?, err : RecipeDataLayerErr?)
    func updateRecipeResult(err : RecipeDataLayerErr?)
    func deleteRecipeResult(err : RecipeDataLayerErr?)
}


//MARK:- Custom Error
enum RecipeDataLayerErr : Error {
    case readDataError(String)
    case addDataError(String)
    case updateDataError(String)
    case deleteDataError(String)
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
    private lazy var realmUtil : RealmUtil = RealmUtil()
    
    
    //MARK: - Inits
    private init() {
        setupDataLayer()
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
            addRealmRecipe(name: name, type: type, picPath: imagePath, ingredients: ingredients, steps: steps)
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
    }
    
    
    
    //convert and save
    func updateRecipe(oldRecipe : Recipe, name: String, type: String, image: UIImage, ingredients: String, steps: String) {
        do{
            let imgPath = try saveImage(name: name, image: image)
            updateRealmRecipe(oldRecipe: oldRecipe, newName: name, newType: type, newPicPath: imgPath, newIngredients: ingredients, newSteps: steps)
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
    }
    
    
    
    func deleteRecipe(oldRecipe : Recipe) {
        do{
            //remove old image
            try fileUtil.deleteFile(filePath: oldRecipe.picturePath)
            
            //remove recipe
            deleteRealmRecipe(recipe: oldRecipe)
        }catch{
            fatalError("Fail save image: \(error.localizedDescription)")
        }
    }
}




//MARK:- Private Helper Funcs
private extension RecipeDataLayer {
    func setupDataLayer() {
            DispatchQueue.global().async {
                do{
                    self.recipeTypes = try ParseUtil().getRecipeTypes()
                    self.getRealmRecipes()
                } catch ParseUtilErr.parseFailed(let err){
                    self.delegate?.readRecipeResult(recipes: [], err: RecipeDataLayerErr.readDataError(err))
                    return
                } catch {
                    self.delegate?.readRecipeResult(recipes: [], err: RecipeDataLayerErr.readDataError(error.localizedDescription))
                    return
                }
            }
        }
    
    
    func hardCodeRecipe() {
        //hard code recipe, 1 recipe for each type
        recipeTypes.forEach { (type) in
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
                addRealmRecipe(name: "Recipe \(randNum)", type: type, picPath: imgPath, ingredients: ingredients, steps: steps)
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




//MARK:- Realm Helper
private extension RecipeDataLayer {
    
    func getRealmRecipes() {
        realmUtil.getAllRecipe { (results, error) in
            if let err = error {
                fatalError("Fail get realm: \(err.localizedDescription)")
            }
            self.recipes = results
            
            //if no recipes, hardcode recipes into realm
            if self.recipes.count == 0 {
                self.hardCodeRecipe()
            }
        }
    }
    
    
    func addRealmRecipe(name : String, type : String, picPath : String, ingredients : String, steps : String) {
        realmUtil.addRecipe(name: name, type: type, picPath: picPath, ingredients: ingredients, steps: steps) { (result, err) in
            if let err = err {
                self.delegate?.addRecipeResult(recipe: nil, err: RecipeDataLayerErr.addDataError(err.localizedDescription))
                return
            }
            guard let recipe = result else {
                self.delegate?.addRecipeResult(recipe: nil, err: RecipeDataLayerErr.addDataError("Recipe missing"))
                return
            }
            self.recipes.append(recipe)
            self.delegate?.addRecipeResult(recipe: recipe, err: nil)
        }
    }
    
    
    func updateRealmRecipe(oldRecipe : Recipe,
                           newName : String,
                           newType : String,
                           newPicPath : String,
                           newIngredients : String,
                           newSteps : String
                           ) {
        let oldImagePath = oldRecipe.picturePath
        realmUtil.updateRecipe(oldRecipe: oldRecipe, newName: newName, newType: newType, newPicPath: newPicPath, newIngredients: newIngredients, newSteps: newSteps) { (err) in
            if let err = err {
                self.delegate?.updateRecipeResult(err: RecipeDataLayerErr.updateDataError(err.localizedDescription))
                return
            }
            
            do{
                //remove old image
                try self.fileUtil.deleteFile(filePath: oldImagePath)
                self.delegate?.updateRecipeResult(err: nil)
            }catch{
                self.delegate?.updateRecipeResult(err: RecipeDataLayerErr.updateDataError(error.localizedDescription))
            }
        }
    }
    
    
    func deleteRealmRecipe(recipe : Recipe) {
        realmUtil.deleteRecipe(recipe: recipe) { (err) in
            if let err = err {
                self.delegate?.deleteRecipeResult(err: RecipeDataLayerErr.deleteDataError(err.localizedDescription))
                return
            }
            self.recipes.removeAll(where: { $0 == recipe })
            self.delegate?.deleteRecipeResult(err: nil)
        }
    }
}
