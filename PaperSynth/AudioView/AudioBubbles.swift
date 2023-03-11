//
//  AudioBubbles.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/29/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import AudioKit
import AudioKitUI
import Foundation
import UIKit
import SwiftUI

/**
 The AudioBubble class handles construction of the control center-esque bubbles for controls
 */

class AudioBubble: UICollectionViewCell {

//    lazy var host: UIHostingController = { return UIHostingController(rootView: myKnob(params: [Parameter]())) }()
    
    private(set) var host: UIHostingController<myKnob>?
    var label: UILabel = {
        let objLabel = UILabel(frame: CGRect(x: 17, y: 10, width: 123, height: 40))
        objLabel.font = UIFont(name: "AvenirNext-Bold", size: 14.0)
        objLabel.textColor = .white
        objLabel.textAlignment = .left
        objLabel.lineBreakMode = .byWordWrapping
        objLabel.numberOfLines = 0
        return objLabel
    }()

    

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        
    }
    
    public func embed(in parent:UIViewController, withParams params: [Parameter]){
        if let host = self.host{
            host.rootView = myKnob(params: params)
            host.view.layoutIfNeeded()
        } else {
            let host = UIHostingController(rootView: myKnob(params: params))
            parent.addChildViewController(host)
            host.didMove(toParent: parent)
            
            host.view.frame = self.contentView.bounds
            self.contentView.addSubview(host.view)
            self.host = host
        }
        
    }
    
    deinit {
        host?.willMove(toParent: nil)
        host?.view.removeFromSuperview()
        host?.removeFromParentViewController()
        host = nil
        print("Cleaned up!")
    }
    
    
    private func setupView(){
        host?.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(host!.view)
        NSLayoutConstraint.activate([
                    host!.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                    host!.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                    host!.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    host!.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
