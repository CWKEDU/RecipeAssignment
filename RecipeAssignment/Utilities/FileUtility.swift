//
//  FileManger.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import Foundation


enum FileUtilityErr : Error {
    case writeFail(String)
    case readFail(String)
}


class FileUtility {
    
    private lazy var fileManager = FileManager.default
    private var semaphore = DispatchSemaphore(value: 0)
    private lazy var documentDirectory : URL = {
        do{
            let directory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
             return directory
        }catch{
            fatalError("Fail init user document directory")
        }
    }()
    
    
    //write & return final url path
    func writeData(fileName : String, imageData : Data) throws -> String {
        var filePath : String = ""
        var resultErr : Error? = nil
        
        do {
            //Enhancement: add check & generate unique file name
            
            //check if file exist, generate unique name if needed
            var path : URL?
            var uniqueName : String = ""
            var exist : Bool = false
            repeat {
                let rand = Int.random(in: 0 ... Int.max )
                uniqueName = "\(fileName)_\(rand).jpg"
                path = documentDirectory.appendingPathComponent(uniqueName)
                exist = fileManager.fileExists(atPath: path!.path)
            } while (exist == true)
            
            try imageData.write(to: path!)
            filePath = path!.path
            semaphore.signal()
        } catch {
            resultErr = error
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let err = resultErr {
            throw FileUtilityErr.writeFail(err.localizedDescription)
        }
        
        guard !(filePath.isEmpty) else {
            throw FileUtilityErr.writeFail("Url Missing")
        }
    
        return filePath
    }

    
    func readData(filePath : String) throws -> Data {
        let url = URL(fileURLWithPath: filePath)
        do {
            return try Data(contentsOf: url)
        } catch {
            throw FileUtilityErr.readFail(error.localizedDescription)
        }
    }
    
    
    func deleteFile(filePath : String) throws {
        if fileManager.fileExists(atPath: filePath) == false {
            return
        }
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch {
            throw error
        }
        
    }
    
}
