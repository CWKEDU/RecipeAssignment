//
//  ImagePickerHelper.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit


//MARK:- Custom Error
enum ImagePickerHelperError : Error {
    case FailGetImage(String)
    case UserCancelled(String)
}



//MARK:- Class Main
class ImagePickerHelper : NSObject {
    
    //MARK:- Vars
    private lazy var imagePicker : UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        return pickerController
    }()
    private var vc : UIViewController?
    private var image : UIImage?
    private var error : ImagePickerHelperError?
    
    private lazy var semaphore : DispatchSemaphore = DispatchSemaphore(value: 0)
    
}



//MARK:- Main Call Function
extension ImagePickerHelper {
    
    func showPickImageOption(vc : UIViewController) throws -> UIImage {
        self.vc = vc
        self.image = nil
        self.error = nil

        //show image picker option
        DispatchQueue.main.async {
            self.showAddImageOption()
        }
        
        //wait for result
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let err = error {
            throw err
        }
        
        guard let image = image else {
            throw ImagePickerHelperError.FailGetImage("Image nil")
        }
        
        return image
    }
    
}




//MARK:- Private Helper Functions
private extension ImagePickerHelper {
    
    func showAddImageOption() {
        
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        let alert = UIAlertController(title: "Add Photo", message: "Please choose a method to add photo", preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Use Camera", style: .default) { (action) in
            self.showCamera()
        }
        let actionPicker = UIAlertAction(title: "Use Photo Library", style: .default) { (action) in
            self.showImagePicker()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCamera)
        alert.addAction(actionPicker)
        alert.addAction(actionCancel)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func showCamera() {
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        imagePicker.sourceType = .camera
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func showImagePicker() {
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func setGetImageFailError(message : String) {
        error = ImagePickerHelperError.FailGetImage(message)
        semaphore.signal()
    }
}



//MARK:- UIImagePickerControllerDelegate
extension ImagePickerHelper : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        vc.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            setGetImageFailError(message: "Original image missing")
            return
        }
        
        self.image = image
        semaphore.signal()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.error = ImagePickerHelperError.UserCancelled("User cancelled")
        semaphore.signal()
    }
}


extension ImagePickerHelper : UINavigationControllerDelegate {
    
}

