//
//  ViewController.swift
//  
//
//  Created by Ayush verma on 05/02/20.
//


import UIKit
import AWSS3
import AWSCognito

class ViewController: UIViewController {
    
    let bucketName = "newblogbucket"
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    
    //AWSS3TransferManager
    func AWSS3TransferManagerUploadFunction(with resource: String, type: String) {   //1
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!  //2
        let localImageUrl = URL(fileURLWithPath: localImagePath)
        
        let request = AWSS3TransferManagerUploadRequest()!
        request.bucket = bucketName  //3
        request.key = key  //4
        request.body = localImageUrl
        request.acl = .publicReadWrite  //5
        
        //6
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith(executor: AWSExecutor.mainThread()) { (task) -> Any? in
            if let error = task.error {
                print(error)
            }
            if task.result != nil {   //7
                print("Uploaded \(key)")
                //do any task
            }
            return nil
        }
        
    }
    
    
    
    //AWSS3TransferUtility
    func AWSS3TransferUtilityUploadFunction(with resource: String, type: String){
        
        let key = "\(resource).\(type)"
        let localImagePath = Bundle.main.path(forResource: resource, ofType: type)!  //2
        let localImageUrl = URL(fileURLWithPath: localImagePath)
        
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
        
    
        
        AWSS3TransferUtility.default().uploadFile(localImageUrl, bucket: bucketName, key: String(key), contentType: resource, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
            if(task.error != nil){
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if(task.result != nil){
                print("Starting upload...")
            }
            return nil
        })
    }
    
    
    
    @IBAction func transferManagerButton(_ sender: Any) {
        AWSS3TransferManagerUploadFunction(with: "sample", type: "MOV")
    }
    
    
    @IBAction func transferUtilityButton(_ sender: Any) {
        AWSS3TransferUtilityUploadFunction(with: "earth", type: "png")
    }
    

}
