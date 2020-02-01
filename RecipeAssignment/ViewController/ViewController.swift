//
//  ViewController.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK:- Vars
    //recipes
    private lazy var recipeDataLayer : RecipeDataLayer = {
        return RecipeDataLayer.shared
    }()
    private var recipeTypes : [String] = [] {
        didSet{
            setupSearchScope()
        }
    }
    private var recipes : [Recipe] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    private var selecteRecipeIndex : Int = 0
    
    
    //search bar
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    private var isSearchActive : Bool {
        if Thread.isMainThread {
            return checkIfSearchActive()
        }
        
        var isActive = false
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.main.async {
            isActive = self.checkIfSearchActive()
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        
      return isActive
    }
    private var currentSearchText : String? {
        guard let text = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        guard text.isEmpty == false else {
            return nil
        }
        return text
    }
    private var currentSearchType : String? = nil {
        didSet{
            //trigger search again
            filterResult()
        }
    }
    
    
    
    //MARK:- Outlets
    //interface builder
    @IBOutlet weak var tableView: UITableView!
    
    
    //programitacally
    private lazy var searchController : UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        return searchController
    }()
    
    
    
    
    
    //MARK:- Overwrites Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup search controller
        setupSearchController()
        
        //setup table view
        setupTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //register to listen to new recipe
        recipeDataLayer.delegate = self
    }
    
}



//MARK:- Private Helper Function
private extension ViewController {
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Recipe"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setupSearchScope()
        searchController.searchBar.delegate = self
    }
    
    
    func setupSearchScope() {
        DispatchQueue.main.async {
            //reset previous selected scope
            self.currentSearchType = nil
            
            var recipeTypeScope = ["All"]
            recipeTypeScope.append(contentsOf: self.recipeTypes)
            self.searchController.searchBar.scopeButtonTitles = recipeTypeScope
        }
    }
    
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    
}



//MARK:- RecipeDataLayerDelegate
extension ViewController : RecipeDataLayerDelegate {
    func recipesChanges(recipes: [Recipe]) {
        //trigger search again with new dataset
        filterResult()
    }
    
    func recipeTypeChanges(recipeTypes: [String]) {
        self.recipeTypes = recipeTypes
    }
}




//MARK:- Search Result Controller
private extension ViewController {
    
    func checkIfSearchActive() -> Bool {
        let searchActive = self.searchController.isActive
        let searchCriterialActive = (!self.isSearchBarEmpty) || (self.currentSearchType != nil)
        return searchActive && searchCriterialActive
    }
    
    func filterResult() {
        //if no search active, just replace the search result
        guard isSearchActive == true else {
            self.recipes = recipeDataLayer.getRecipes()
            return
        }
        
        //filter result
        self.recipes = recipeDataLayer.getRecipes().filter({ (recipe) -> Bool in
            //match type, immediate disqualify if not match
            if let searchType = currentSearchType {
                if recipe.recipeType != searchType {
                    return false
                }
            }
            
            //if name not match, direct disqualify
            if let searchText = currentSearchText {
                if recipe.recipeName.lowercased().contains(searchText.lowercased()) == false {
                    return false
                }
            }
            
            return true
        })
    }
}

extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterResult()
    }
}

extension ViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        
        guard let scopeButtonTitles =  searchBar.scopeButtonTitles else {
            fatalError("Scope button titles not set")
        }
        
        guard selectedScope != 0 else {
            self.currentSearchType = nil
            return
        }
        
        self.currentSearchType = scopeButtonTitles[selectedScope]
    }
}




//MARK:- TableView
extension ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableCellID.RecipeCell, for: indexPath) as? UITableViewCell else {
            fatalError("Table view cell not set up correctly")
        }
        
        let recipe = recipes[indexPath.row]
        cell.textLabel?.text = recipe.recipeName
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selecteRecipeIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




