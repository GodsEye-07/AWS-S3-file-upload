//
//  AWSS3TransferUtility.swift
//  AWSS3Blog
//
//  Created by Ayush verma on 05/02/20.
//  Copyright © 2020 Ayush verma. All rights reserved.
//

import UIKit
import AWSS3
import AWSCognito

class AWSS3TransferUtilityViewController: UIViewController {
    
    let bucketName = "newblogbucket"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    func uploadFile(with resource: String, type: String){
        
        let key = "\(resource).\(type)"
        let resource = Bundle.main.path(forResource: "\(resource)", ofType: "\(type)")!
        let videoUrl = URL(fileURLWithPath: resource)
        
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            print(progress.fractionCompleted)
            //do any changes once the upload is finished here
            if progress.isFinished{
                print("Upload Finished...")
            }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")

        completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:NSError?) -> Void in
            if(error != nil){
                print("Failure uploading file")
                
            }else{
                print("Success uploading file")
            }
        } as? AWSS3TransferUtilityUploadCompletionHandlerBlock
        
    
        
        AWSS3TransferUtility.default().uploadFile(videoUrl, bucket: bucketName, key: String(key), contentType: resource, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    
    @IBAction func uploadFileButtonTapped(_ sender: Any) {
        uploadFile(with: "earth", type: "png")
    }

}
