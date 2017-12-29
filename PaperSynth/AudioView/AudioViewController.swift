//
//  AudioViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import UIKit

class AudioViewController: UIViewController, UICollectionViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("loaded!")
        view.backgroundColor = UIColor(white: 0.4, alpha: 0.8)
        view.alpha = 1
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(blurEffectView)
    }

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
