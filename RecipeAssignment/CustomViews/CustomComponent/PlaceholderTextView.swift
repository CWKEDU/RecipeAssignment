//
//  PlaceholderTextView.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit



//MARK:- Custom Textview With Placeholder
class PlaceholderTextView: UITextView {
    
    //MARK:- Constants
    private let placeholderColor = UIColor.systemGray
    private let mainTextColor = UIColor.label
    
    
    
    //MARK:- Vars
    private var isEmpty = true {
        didSet{
            if isEmpty {
                showPlaceholder()
            } else {
                attributedText = nil
                textColor = mainTextColor
            }
        }
    }
    private var preferedFont = UIFont.preferredFont(forTextStyle: .body)
    private var placeholder = "Default Placeholder" {
        didSet{
            //update view if is empty
            if isEmpty {
                showPlaceholder()
            }
        }
    }
    private var shouldJustify = false
    
    
    override var text: String! {
        didSet{
            setDisplayText(text: text)
        }
    }
    
    
    
   
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        translatesAutoresizingMaskIntoConstraints = false
        delegate = self
        
        //add done button on keyboard
        addDoneButtonOnKeyboard()
        
        //init placeholder
        showPlaceholder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func showPlaceholder() {
        //set state to empty, then show placeholder
        let attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
            NSAttributedString.Key.font : preferedFont,
            NSAttributedString.Key.foregroundColor : placeholderColor
        ])
        attributedText = attributedPlaceholder
    }
    
}



//MARK:- Main Call Functions
extension PlaceholderTextView {
    
    //necessary setup
    func setup(placeholder : String, fontType : UIFont = UIFont.preferredFont(forTextStyle: .body), justify : Bool = false) {
        self.placeholder = placeholder
        self.preferedFont = fontType
        self.shouldJustify = justify
    }
    
    
    //set text to be display, for hardcode or display
    func setDisplayText(text : String) {
        //check if text is empty, update state
        if text.isEmpty {
            isEmpty = true
            return
        }
        
        //not empty, update state & add text
        isEmpty = false
        
        let attributedPlaceholder = NSAttributedString(string: text, attributes: [
            NSAttributedString.Key.font : preferedFont,
            NSAttributedString.Key.foregroundColor : mainTextColor
        ])
        attributedText = attributedPlaceholder
        
        if shouldJustify {
            textAlignment = .justified
        }
    }
    
    
    //get final text setted before submit
    func getSetText() -> String? {
        if isEmpty || text.isEmpty {
            return nil
        }
        return text
    }
}




//MARK:- UITextViewDelegate
extension PlaceholderTextView : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
           //if showing placeholder, clear text
           if isEmpty {
               isEmpty = false
           }
       }
       
       func textViewDidEndEditing(_ textView: UITextView) {
            //if text is empty set state back to show placeholder
           if text.isEmpty {
               isEmpty = true
           }
       }
}
