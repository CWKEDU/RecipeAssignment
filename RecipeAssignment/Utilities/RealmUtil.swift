//
//  RealmHelper.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import Foundation
import RealmSwift




class RealmUtil {
    private var realmQueue : DispatchQueue = DispatchQueue.main
    private lazy var recipes : [Recipe] = []
}



//MARK:- Main Call Funcs
extension RealmUtil {
    
    func getAllRecipe(callback : @escaping([Recipe], Error?) -> Void) {
        self.recipes = []
        realmQueue.async {
            do{
                let realm = try Realm()
                let results = realm.objects(Recipe.self)
                self.recipes = Array(results)
                callback(self.recipes, nil)
            } catch {
                callback(self.recipes, error)
            }
        }
    }
    
    
    func addRecipe(name : String,
                   type : String,
                   picPath : String,
                   ingredients : String,
                   steps : String,
                   callback : @escaping((Recipe?, Error?) -> Void))  {
        realmQueue.async {
            do{
                //create recipe
                let realm = try Realm()
                let recipe = Recipe(name: name, type: type, picPath: picPath, ingredients: ingredients, steps: steps)
                
                //add to realm
                try realm.write {
                    realm.add(recipe)
                }
                
                //add to own array
                self.recipes.append(recipe)
                
                //callback
                callback(recipe, nil)
            }catch{
                callback(nil, error)
            }
        }
    }
    
    
    func updateRecipe(oldRecipe : Recipe,
                      newName : String? = nil,
                      newType : String? = nil,
                      newPicPath : String? = nil,
                      newIngredients : String? = nil,
                      newSteps : String? = nil,
                      callback : @escaping((Error?) -> Void)
                      ) {
        realmQueue.async {
            do{
                let realm = try Realm()
                try realm.write({
                    if let name = newName {
                        oldRecipe.recipeName = name
                    }
                    if let type = newType {
                        oldRecipe.recipeType = type
                    }
                    if let picPath = newPicPath {
                        oldRecipe.picturePath = picPath
                    }
                    if let ingredients = newIngredients {
                        oldRecipe.ingredients = ingredients
                    }
                    if let steps = newSteps {
                        oldRecipe.steps = steps
                    }
                    
                    callback(nil)
                })
            }catch{
                callback(error)
            }
        }
    }
    
    
    
    func deleteRecipe(recipe : Recipe, callback : @escaping((Error?) -> Void)) {
        realmQueue.async {
            do{
                let realm = try Realm()
                try realm.write({
                    realm.delete(recipe)
                    self.recipes.removeAll(where: { $0 == recipe})
                    callback(nil)
                })
            }catch{
                callback(error)
            }
        }
    }
}



