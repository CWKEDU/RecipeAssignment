//
//  AddRecipeVC.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit


class AddRecipeVC: UIViewController {
    
    //MARK: Conts
    enum ViewState {
        case add
        case edit
        case view
    }
    

    
    //MARK:- Vars
    private lazy var recipeDataLayer : RecipeDataLayer = {
        return RecipeDataLayer.shared
    }()
    private lazy var recipeTypes : [String] = {
        return recipeDataLayer.getRecipeTypes()
    }()
    var recipe : Recipe? = nil {
        didSet{
            //update view here
        }
    }
    
    private var selectedRecipeType : Int? = nil {
        didSet{
            guard let type = selectedRecipeType else {
                return
            }
            setRecipeTypeBtn.setTitle(recipeTypes[type], for: .normal)
        }
    }
    
    //editing states
    var editState : ViewState = .add {
        didSet {
            self.updateSetRecipeBtnState(btn: setRecipeTypeBtn)
            self.titleTextView.isEditable = editEnable
            self.ingredientTxtView.isEditable = editEnable
            self.stepTxtView.isEditable = editEnable
        }
    }
    private var editEnable : Bool {
        switch editState {
        case .view:
            return false
        default:
            return true
        }
    }
    
    //image picker
    private lazy var imagePickerHelper = ImagePickerHelper()
    
    //for setting new image ratio
    private var imageRatioConstraint : NSLayoutConstraint? = nil
    
    
    
    //MARK:- Outlets
    //interface builder
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var rightBarBtn: UIBarButtonItem!
    
    
    //programatically
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    
    
    //banner image with button
    private lazy var recipeImgBtn : ImageButton = {
        //init with a button
        let selectBtn = ImageButton()
        //set on click listener
        if editEnable {
            selectBtn.addTarget(self, action: #selector(setRecipeImage), for: .touchUpInside)
        }
        return selectBtn
    }()
    
    
    //Recipe Name
    private lazy var titleTextView : PlaceholderTextView = {
        let textView = PlaceholderTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.setup(placeholder: "Recipe Name", fontType: UIFont.preferredFont(forTextStyle: .headline))
        textView.isEditable = editEnable
        return textView
    }()
    
    
    //Recipe Type
    private lazy var recipeType : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "Recipe Type:"
        
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        view.addSubview(setRecipeTypeBtn)
        setRecipeTypeBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        setRecipeTypeBtn.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10).isActive = true
        setRecipeTypeBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        setRecipeTypeBtn.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: 0).isActive = true
        
        view.layoutIfNeeded()
        
        return view
    }()
    private lazy var setRecipeTypeBtn : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .leading
        button.addTarget(self, action: #selector(showRecipeTypePickerView), for: .touchUpInside)
        if editState == .add {
            button.setTitle("Choose Type", for: .normal)
        } else {
            guard let recipe = self.recipe else {
                fatalError("if is edit or view, must have recipe!!!")
            }
            button.setTitle(recipe.recipeType, for: .normal)
        }
        updateSetRecipeBtnState(btn: button)
        return button
    }()
    
    
    //ingredients
    private lazy var ingredientView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.text = "Ingredients:"
        
        view.addSubview(label)
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        view.addSubview(ingredientTxtView)
        ingredientTxtView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
        ingredientTxtView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        ingredientTxtView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        ingredientTxtView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        view.layoutIfNeeded()
        return view
    }()
    private lazy var ingredientTxtView : PlaceholderTextView = {
        let textView = PlaceholderTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.setup(placeholder: "Ingredients List", fontType: UIFont.preferredFont(forTextStyle: .body))
        textView.isEditable = editEnable
        return textView
    }()
    
    
    //steps
    private lazy var stepView : UIView = {
           let view = UIView()
           view.translatesAutoresizingMaskIntoConstraints = false
           
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.font = UIFont.preferredFont(forTextStyle: .subheadline)
           label.text = "Steps:"
           
           view.addSubview(label)
           label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
           label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
           label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
           
           view.addSubview(stepTxtView)
           stepTxtView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
           stepTxtView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
           stepTxtView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
           stepTxtView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
           
           view.layoutIfNeeded()
           return view
       }()
       private lazy var stepTxtView : PlaceholderTextView = {
           let textView = PlaceholderTextView()
           textView.translatesAutoresizingMaskIntoConstraints = false
           textView.isScrollEnabled = false
           textView.setup(placeholder: "Steps List", fontType: UIFont.preferredFont(forTextStyle: .body))
           textView.isEditable = editEnable
           return textView
       }()
    
    
    
    
    
    
    //MARK:- Overwrites Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutViews()
        contentView.setAutoDismissKeyboard()
        
    }
    
    
   
    //MARK:- Btn Actions
    @IBAction func rightBarBtnClicked(_ sender: Any) {
        switch editState {
        case .add:
            //if is add mode, directly add new recipe
            addRecipe()
        case .view:
            print("not yet implement")
        case .edit:
            print("not yet implement")
        }
        
        
        
        
        
        //if is view mode, show edit or delete option
        //- udpate btn to "Done" if choose edit
        //- if delete, delete data then pop back to parent
        
        //if is editing mode, show option to discard edit or commit
        //- if commit, add to database, then back to view state
        //- if is discard, load back data in "recipe", back to view state
        
        
        
    }
    
    
    
    
}




//MARK:- Private Helper Function
private extension AddRecipeVC {
    
    func layoutViews() {
        //define constraint constants
        let mainContentPadding : CGFloat = 15
        let imageRatio_WidthToHeight : CGFloat = 320/640
        
        //add contents to scrollview content
        contentView.addSubview(recipeImgBtn)
        recipeImgBtn.topAnchor.constraint(equalTo: contentView.topAnchor, constant: mainContentPadding).isActive = true
        recipeImgBtn.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainContentPadding).isActive = true
        recipeImgBtn.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainContentPadding).isActive = true
        imageRatioConstraint = recipeImgBtn.heightAnchor.constraint(equalTo: recipeImgBtn.widthAnchor, multiplier: imageRatio_WidthToHeight)
        imageRatioConstraint?.isActive = true
        
        
        //recipe name
        contentView.addSubview(titleTextView)
        titleTextView.topAnchor.constraint(equalTo: recipeImgBtn.bottomAnchor, constant: mainContentPadding).isActive = true
        titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainContentPadding).isActive = true
        titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainContentPadding).isActive = true
        
        
        //recipe type
        contentView.addSubview(recipeType)
        recipeType.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: mainContentPadding).isActive = true
        recipeType.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainContentPadding).isActive = true
        recipeType.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainContentPadding).isActive = true
        
        
        //ingredient
        contentView.addSubview(ingredientView)
        ingredientView.topAnchor.constraint(equalTo: recipeType.bottomAnchor, constant: mainContentPadding).isActive = true
        ingredientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainContentPadding).isActive = true
        ingredientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainContentPadding).isActive = true
        
        
        //steps
        contentView.addSubview(stepView)
        stepView.topAnchor.constraint(equalTo: ingredientView.bottomAnchor, constant: mainContentPadding).isActive = true
        stepView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: mainContentPadding).isActive = true
        stepView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -mainContentPadding).isActive = true
        
        
        //closing up
        stepView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -mainContentPadding).isActive = true
        
        view.layoutIfNeeded()
    }
    
    
    
    @objc func setRecipeImage(sender : ImageButton) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let image = try self.imagePickerHelper.showPickImageOption(vc: self)
                
                //update btn constraint ratio
                DispatchQueue.main.async {
                    let newRatio : CGFloat = image.size.height / image.size.width
                    self.imageRatioConstraint?.isActive = false
                    self.imageRatioConstraint = self.recipeImgBtn.heightAnchor.constraint(equalTo: self.recipeImgBtn.widthAnchor, multiplier: newRatio)
                    self.imageRatioConstraint?.isActive = true
                    self.view.layoutIfNeeded()
                }
                
                self.recipeImgBtn.updateImg(image: image)
            } catch ImagePickerHelperError.FailGetImage(let errMsg) {
                self.showSimpleAlert(title: "Get Image Error", message: errMsg)
            } catch ImagePickerHelperError.UserCancelled(_) {
                //do nothing
            } catch {
                self.showSimpleAlert(title: "Unexpected Error", message: error.localizedDescription)
            }
        }
    }
    
    
    func updateSetRecipeBtnState(btn : UIButton) {
        if editState == .view {
            btn.setTitleColor(.label, for: .normal)
            btn.isEnabled = false
        } else {
            btn.setTitleColor(.systemBlue, for: .normal)
            btn.isEnabled = true
        }
    }
    
    
    
    @objc func showRecipeTypePickerView() {
        let vc = UIViewController()
        vc.view.addSubview(self.pickerView)
        var constraints : [NSLayoutConstraint] = []
        constraints.append(pickerView.topAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.topAnchor, constant: 0))
        constraints.append(pickerView.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 0))
        constraints.append(pickerView.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: 0))
        constraints.append(pickerView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: 0))
        constraints.forEach({$0.isActive = true})
        vc.view.layoutIfNeeded()
        
        let dismissPickerView = {
            constraints.forEach({$0.isActive = false})
            self.pickerView.removeFromSuperview()
            vc.view.layoutIfNeeded()
        }
        
        
        let editRadiusAlert = UIAlertController(title: "Choose distance", message: "", preferredStyle: .alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
            dismissPickerView()
        }))
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            dismissPickerView()
        }))
        self.present(editRadiusAlert, animated: true)
    }
    
    
    func addRecipe() {
        //validate: Recipe Name, recipeType, picture, ingredients, steps
        guard let recipeImg = recipeImgBtn.getImage() else {
            showSimpleAlert(title: "Image Empty", message: "Must set image!")
            return
        }
        guard let recipeName = titleTextView.getSetText() else {
            showSimpleAlert(title: "Title Empty", message: "Must set title!")
            return
        }
        guard let type = setRecipeTypeBtn.title(for: .normal),  recipeTypes.contains(type) else {
            showSimpleAlert(title: "Invalid Type", message: "Invalid Recipe Type!")
            return
        }
        guard let ingredients = ingredientTxtView.getSetText() else {
            showSimpleAlert(title: "Ingredient Empty", message: "Must set ingredient!")
            return
        }
        guard let steps = stepTxtView.getSetText() else {
            showSimpleAlert(title: "Steps Empty", message: "Must set steps!")
            return
        }
        
        
        showSimpleAlert(title: "Check OK", message: "Proceed")
        
        
        
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
