//
//  AddRecipeVC.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit


class AddRecipeVC: UIViewController {
    
    //MARK:- Outlets
    //interface builder
    @IBOutlet private weak var pickerView: UIPickerView!
    
    
    
    //MARK:- Vars
    private lazy var recipeDataLayer : RecipeDataLayer = {
        return RecipeDataLayer.shared
    }()
    private lazy var recipeTypes : [String] = {
        return recipeDataLayer.getRecipeTypes()
    }()
    private var recipes : [Recipe] = [] {
        didSet {
            //reset picker view
            DispatchQueue.main.async {
                self.pickerView.reloadAllComponents()
            }
        }
    }
    private var selectedRecipeType : Int? = nil
    
    
    
    //MARK:- Overwrites Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //init picker view
        setupPickerView()
    }
    
    
   
}




//MARK:- Private Helper Function
private extension AddRecipeVC {
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
}




//MARK:- UIPickerViewDelegate
extension AddRecipeVC : UIPickerViewDelegate {
    //detect select
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        print("Selected recipe: \(recipeTypes[row])")
        self.selectedRecipeType = row
    }
}


//MARK:- UIPickerViewDataSource
extension AddRecipeVC : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return recipeTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return recipeTypes[row]
    }
}
