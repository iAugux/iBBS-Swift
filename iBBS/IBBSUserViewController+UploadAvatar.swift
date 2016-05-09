//
//  IBBSUserViewController+UploadAvatar.swift
//  iBBS
//
//  Created by Augus on 4/28/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Foundation
import MobileCoreServices
import Alamofire
import Qiniu
import KYNavigationProgress


private let thumbnailSize = CGSizeMake(200, 200)

private var avatarImageFilePath = {
    return (Utils.documentPath as NSString).stringByAppendingPathComponent("ibbs_current_user_avatar.png")
}()

extension IBBSUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        guard let type = info[UIImagePickerControllerMediaType] where type as! CFString == kUTTypeImage else { return }
        
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        performSelector(#selector(saveImage(_:)), withObject: image, afterDelay: 0.5)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: -
    
    func changeAvatar() {
        
        IBBSContext.loginIfNeeded(alertMessage: PLEASE_LOGIN) { 
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let pickPhoto = UIAlertAction(title: "Photos", style: .Default) { (_) in
                
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            let takePhoto = UIAlertAction(title: "Take Photo", style: .Default) { (_) in
                
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            alertController.addAction(pickPhoto)
            alertController.addAction(takePhoto)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    @objc private func saveImage(image: UIImage) {
        
        navigationItem.leftBarButtonItem?.action
        
        let fileManager: NSFileManager = NSFileManager.defaultManager()
        
        if fileManager.fileExistsAtPath(avatarImageFilePath) {
            _ = try? fileManager.removeItemAtPath(avatarImageFilePath)
        }
        
        guard !fileManager.fileExistsAtPath(avatarImageFilePath) else {
            NSLog("remove file failed")
            return
        }
        
        let thumbnail = thumbnailWithImageWithoutScale(image, size: thumbnailSize)
        
        guard let _ = UIImagePNGRepresentation(thumbnail)?.writeToFile(avatarImageFilePath, atomically: false) else { return }
        
        userImageView._changeImageWithAnimation(thumbnail)
        
        uploadImage { (url) in
            
            let key = IBBSLoginKey()
            
            APIClient.defaultClient.changeAvatar(key.uid, token: key.token, url: url, success: { (json) in
                
                // reset process
                self.navigationController?.progress = 0
                
                let model = IBBSModel(json: json)
                
                if model.success {
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), style: .Plain, target: self, action: #selector(IBBSUserViewController.showActionSheet))
                    
                    IBBSToast.make(model.message, delay: 0, interval: 1.5)
                    
                    // modified avatar url on disk
                    IBBSLoginKey.modifyAvatarUrl(url)
                    
                } else {
                    IBBSToast.make(model.message, delay: 0, interval: 2)
                }
                
                }, failure: { (error) in
                    DEBUGLog(error)
                    IBBSToast.make(TRY_AGAIN, delay: 0, interval: 2)
            })
        }
    }
    
    private func thumbnailWithImageWithoutScale(image: UIImage, size asize: CGSize) -> UIImage {

        let oldsize = image.size
        var rect = CGRectZero
        
        if asize.width / asize.height > oldsize.width / oldsize.height {
            rect.size.width = asize.height * oldsize.width / oldsize.height
            rect.size.height = asize.height
            rect.origin.x = (asize.width - rect.size.width) / 2
            rect.origin.y = 0
            
        } else {
            rect.size.width = asize.width
            rect.size.height = asize.width * oldsize.height / oldsize.width
            rect.origin.x = 0
            rect.origin.y = (asize.height - rect.size.height) / 2
        }
        
        UIGraphicsBeginImageContext(asize)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.clearColor().CGColor)
        UIRectFill(CGRect(origin: CGPointZero, size: asize))
        image.drawInRect(rect)
        let newimage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newimage
    }
    
}


// MARK: - 

private var cancelUploading: Bool = false

extension IBBSUserViewController {
    
    @objc private func alertWhetherToCancel() {

        AlertController.alertWithCancelAction(title: UPLOADING, actionTitle: YES, cancelTitle: NO, completionHandler: {
            cancelUploading = true
            }, canceledHandler: {
                cancelUploading = false
        })
    }
}


// MARK: - QiNiu

extension IBBSUserViewController {
    
    private typealias FeedbackURL = (url: String) -> ()
    
    private func uploadImage(completion : FeedbackURL) {
        
        let uploding = NSLocalizedString("Uploading...", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: uploding, style: .Plain, target: self, action: #selector(alertWhetherToCancel))
        
        navigationController?.progressTintColor = CUSTOM_THEME_COLOR
        navigationController?.progressHeight = 3
        
        let path = "http://115.231.183.102:9090/api/quick_start/simple_image_example_token.php"
        
        // get token and domain of QiNiu
        Alamofire.request(.GET, path, parameters: nil).responseSwiftyJSON { (response) in
            
            switch response.result {
            case .Success(let json):
                
                let domain = json["domain"].stringValue
                let token = json["uptoken"].stringValue
                
                self.uploadImageToQiNiu(avatarImageFilePath, token: token, domain: domain, completion: completion)
                
            case .Failure(let error):
                DEBUGLog(error)
            }
        }
    }
    
    private func uploadImageToQiNiu(filePath: String, token: String, domain: String, completion: FeedbackURL) {
        
        let upManager = QNUploadManager()
        
        let uploadOption = QNUploadOption(mime: nil, progressHandler: { (_, percent) in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.progress = percent
            })
            
            }, params: nil, checkCrc: false, cancellationSignal: {
                return cancelUploading
        })
        
        upManager.putFile(filePath, key: nil, token: token, complete: { (info, _, resp) in
            
            DEBUGPrint(info)
            
            guard resp != nil else { return }
            
            guard let key = resp["key"] as? String else { return }
            
            let avatarUrl = (domain as NSString).stringByAppendingPathComponent(key)
            
            completion(url: avatarUrl)
            
            }, option: uploadOption)
        
        
    }
    
}