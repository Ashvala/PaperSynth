//
//  RootView.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//
//  Shoutout to @loudmouth on github for teaching me this last year.

import Foundation
import UIKit


class RootViewController: UIViewController {
    
    /**
     Make sure the status bar is hidden.
     */
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    func set(viewController: UIViewController, completion: (() -> ())? = nil) {

        if let childViewController = self.childViewControllers.first {
            childViewController.willMove(toParentViewController: nil)
            childViewController.view.removeFromSuperview()
            childViewController.removeFromParentViewController()
        }

        addChildViewController(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.frame
        viewController.didMove(toParentViewController: self)
        self.viewController = viewController    
        completion?()
    }
    
    private var viewController: UIViewController!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        definesPresentationContext = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = UIScreen.main.bounds
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.viewController.supportedInterfaceOrientations
    }
    
}
