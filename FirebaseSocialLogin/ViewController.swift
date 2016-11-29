//
//  ViewController.swift
//  FirebaseSocialLogin
//
//  Created by Jesus Adolfo on 11/28/16.
//  Copyright © 2016 Jesus Adolfo. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn
import TwitterKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //check fb version
        print("SDK version \(FBSDKSettings .sdkVersion())")

        //getting fb button
        let fbButton = FBSDKLoginButton()
        fbButton.delegate = self
        fbButton.readPermissions = ["email", "public_profile "]
        
        //custom button for fb
        let fbCustomButton = UIButton()
        fbCustomButton.backgroundColor = .blue
        fbCustomButton.setTitle("Custom FB Login Button", for: .normal)
        fbCustomButton.setTitleColor(.white, for: .normal)
        fbCustomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        fbCustomButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        
        
        //add google button
        let googleButton = GIDSignInButton()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        //custom google button
        let googleCustomButton = UIButton(type: .system)
        googleCustomButton.backgroundColor = .orange
        googleCustomButton.setTitle("Custom Google Login Button", for: .normal)
        googleCustomButton.setTitleColor(.white, for: .normal)
        googleCustomButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        googleCustomButton.addTarget(self, action: #selector(handleCustomGoogleLogin), for: .touchUpInside)
        
        
        //twitter login button
        let twitterButton = TWTRLogInButton { (session, error) in
            if let err = error {
                print("Failed to login with twitter", err)
            }
            
            print("Successfully logged in through twitter !!")
            
            
            //twitter with firebase
            guard let token = session?.authToken else { return }
            guard let secret = session?.authTokenSecret else { return }
            let credentials = FIRTwitterAuthProvider.credential(withToken: token, secret: secret)
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                
                if let err = error {
                    print("Failed to login to Firebase with Twitter:", err)
                    return
                }
                print("Successfully created a Firebase-Twitter user:", user?.uid ?? "")
            })
            
        }
        
        
        fbButton.frame = CGRect(x: 16, y: 50, width: view.frame.width-32, height: 50)
        fbCustomButton.frame = CGRect(x: 16, y: 116, width: view.frame.width-32, height: 50)
        googleButton.frame = CGRect(x: 16, y: 176, width: view.frame.width-32, height: 50)
        googleCustomButton.frame = CGRect(x: 16, y: 176 + 66 , width: view.frame.width-32, height: 50)
        twitterButton.frame = CGRect(x: 16, y: 176 + 66 + 66  , width: view.frame.width-32, height: 50)

        
        
        view.addSubview(fbButton)
        view.addSubview(fbCustomButton)
        view.addSubview(googleButton)
        view.addSubview(googleCustomButton)
        view.addSubview(twitterButton)
        
    }
    
    func handleCustomGoogleLogin(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func handleCustomFBLogin() {
        print("calling login from our custom fb button")
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self)
        { (result, err) in
            if err != nil{
                print("Custom FB Login failed", err!)
                return
            }
            
//            print(result?.token.tokenString as Any)
            self.showEmailAddress()
        }
    }

    //IMPORTANT
    //REMEMBER TO ENABLE KEYCHAIN SHARING ON XCODE !!
    // IMPORTANT BEFORE PRODUCTION 
    //REMEMBER TO LOG IN THE FB APP PANEL AND MAKE IT PUBLIC BEFORE PRODUCTION
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook");
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error related to facebook login!!")
            print(error)
            return
        }
        
        
        print("Successfully logged in with facebook")
        showEmailAddress()
        
    }
    
    func showEmailAddress(){
        
        //SETTING UP FIREBASE WITH FACEBOOK
        //REMEMBER TO ENABLE FACEBOOK LOGIN IN THE FIREBASE PANEL
        //APP ID AND SECRET FOR THE FACEBOOK APP PANEL WILL BE REQUIRED!
        
        
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else
        { return }
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our fb user: ", error ?? "")
                return
            }
            print("Sucessfully logged in with our fb user", user ?? "")
        })
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, err) in
            
            
            if err != nil {
                print("Failed to start graph request T_T", err ?? "")
                return
            }
            
            print(result as Any)
        }
    }
}

