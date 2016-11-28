//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by Jesus Adolfo on 11/28/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //getting fb button
        let fbButton = FBSDKLoginButton()
        
        view.addSubview(fbButton)
        
        fbButton.frame = CGRect(x: 16, y: 50, width: view.frame.width-32, height: 50)
    }

    //IMPORTANT
    //REMEMBER TO ENABLE KEYCHAIN SHARING ON XCODE !!
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook");
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook")
    }
}

