//
//  AWSS3TransferManager.swift
//  AWSS3Blog
//
//  Created by Ayush verma on 05/02/20.
//  Copyright © 2020 Ayush verma. All rights reserved.
//

import UIKit
import AWSS3
import AWSCognito

class AWSS3TransferManagerViewController: UIViewController {
    
    let bucketName = "newblogbucket"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func uploadFile(with resource: String, type: String) {   //1
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
    
    @IBAction func uploadFileButtonTapped(_ sender: Any) {
        uploadFile(with: "sample", type: "MOV")
    }
    

}
