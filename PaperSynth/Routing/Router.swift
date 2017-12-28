//
//  AppRootView.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//  Shoutout to @loudmouth on github for teaching me this last year. 

import Foundation
import UIKit

class Router {
    
    let RootController: RootViewController
    
    init() {
        self.appRootViewController = RootController()
    }
    
    func showFirstViewController() {
           showLandingPage()
    }
    
    func showLandingPage() {
        let landingView = UIStoryboard(name: String(describing: LandingViewController.self), bundle: nil).instantiateInitialViewController() as! LandingViewController
        appRootViewController.set(viewController: landingView)
    }
}

