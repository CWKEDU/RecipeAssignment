//
//  ImageButton.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit



class ImageButton: UIButton {
    
    //MARK:- Vars
    private var isSet = false
    private lazy var plusImg : UIImage = {
        let imgConfig = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        guard let btnImg = UIImage(systemName: "plus", withConfiguration: imgConfig) else {
            fatalError("Fail init plus icon")
        }
        return btnImg
    }()
    
    
    
    //MARK:- Overwrite & Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //disable auto layout
        translatesAutoresizingMaskIntoConstraints = false
        
        //set background color
        backgroundColor = UIColor.systemGray6
        
        //border radius
        layer.cornerRadius = 5
        
        imageView?.contentMode = .scaleAspectFill
        
        //set initial image
        updateImg(image: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



//MARK:- Main Call Functions
extension ImageButton {
    //for update img
    func updateImg(image : UIImage?) {
        DispatchQueue.main.async {
            guard let image = image else {
                self.isSet = false
                self.setImage(self.plusImg, for: .normal)
                self.clipsToBounds = true
                return
            }
            
            self.setImage(image, for: .normal)
            self.clipsToBounds = false   //no longer need to round corner after pick image
            self.isSet = true
        }
    }
    
    
    //check state if set before
    func checkIsSet() -> Bool {
        return isSet
    }
    
    
    //get image set
    func getImage() -> UIImage? {
        if isSet == false {
            return nil
        }
        let img = image(for: .normal)
        return img
    }
}
