//
//  AudioViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import UIKit

class AudioViewController: UIViewController {
    var widgetNames: [String]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    init(widgetNames:[String]){
        self.widgetNames = widgetNames
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
