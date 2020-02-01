//
//  ParseUtil.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 01/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import Foundation



//MARK:- Custom Error
enum ParseUtilErr : Error {
    case parseFailed(String)
}



//MARK:- Class Main
class ParseUtil : NSObject {
    
    //MARK:- Consts
    private let xmlFileName = "RecipeTypes"
    private let elementName_RecipeTypes = "RecipeType"
    
    
    //MARK:- Vars
    //store tempt data
    private var currentElementName : String? = nil
    private var tempRecipeType : String = ""
    
    //for check and return after process completed
    private var semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
    private var recipeTypes : [String] = []
    private var parseErr : Error? = nil
    
}



//MARK:- Main Call Functions
extension ParseUtil {
    
    func getRecipeTypes() throws -> [String] {
        self.recipeTypes = []    //clear old data
        self.parseErr = nil
        let xmlName = self.xmlFileName //could be parameter passed in
        
        guard let path = Bundle.main.url(forResource: xmlName, withExtension: "xml") else {
            throw ParseUtilErr.parseFailed("Fail load xml")
        }
        
        guard let parser = XMLParser(contentsOf: path) else {
            throw ParseUtilErr.parseFailed("Fail init XMLParser")
        }
        
        parser.delegate = self
        parser.parse()
        _ = self.semaphore.wait(timeout: .distantFuture)
        
        if let err = parseErr {
            throw ParseUtilErr.parseFailed(err.localizedDescription)
        }
        
        return recipeTypes
    }
    
}



//MARK:- XMLParserDelegate
extension ParseUtil : XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    
        //reset before parse any inner element if needed
        if elementName == elementName_RecipeTypes {
            tempRecipeType = ""
        }

        self.currentElementName = elementName
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == elementName_RecipeTypes {
            self.recipeTypes.append(tempRecipeType)
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            if self.currentElementName == elementName_RecipeTypes {
                self.tempRecipeType += data
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        self.parseErr = parseError
        semaphore.signal()
    }
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        semaphore.signal()
    }
    
}
