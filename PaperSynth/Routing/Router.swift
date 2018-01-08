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

    let rootController: RootViewController

    init() {
        rootController = RootViewController()
    }

    func showFirstViewController() {
        showLandingPage()
    }

    func showLandingPage() {
        guard let landingView = UIStoryboard(name: String(describing: LandingViewController.self), bundle: nil).instantiateInitialViewController() as? LandingViewController else {
            return
        }
        rootController.set(viewController: landingView)
    }

    func showCompiledPage(widgets: [String]) {

        guard let audioView = UIStoryboard(name: String(describing: AudioViewController.self), bundle: nil).instantiateInitialViewController() as? AudioViewController else {
            return
        }
        audioView.configure(widgetNames: widgets)
        rootController.set(viewController: audioView)
    }
}
