//
//  AppDelegate.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        splitViewController.delegate = self
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        Dropbox.setupWithAppKey("4fvpchk1tqk7pds")
        
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        handleDropbox(openURL: url)
        
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as! String, annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        handleDropbox(openURL: url)
        
        return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    private func handleDropbox(openURL url: NSURL) {
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
                NSNotificationCenter.defaultCenter().postNotificationName(DropboxDidLoginNotification.Name, object: nil, userInfo: [DropboxDidLoginNotification.TokenKey : token])
            case .Error(let error, let description):
                NSNotificationCenter.defaultCenter().postNotificationName(DropboxDidLoginNotification.Name, object: nil, userInfo: [DropboxDidLoginNotification.ErrorDescriptionKey : description])
                print("Error \(error): \(description)")
            }
        }
    }
    
    // MARK: - Split view
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

