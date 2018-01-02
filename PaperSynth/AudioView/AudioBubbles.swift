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

/**
 The audiobubble class handles construction of the control center-esque bubbles for controls
 */

class AudioBubble: UICollectionViewCell {

    var Label: UILabel = {
        let objLabel = UILabel(frame: CGRect(x: 17, y: 10, width: 123, height: 40))
        objLabel.font = UIFont(name: "AvenirNext-Bold", size: 14.0)
        objLabel.textColor = .white
        objLabel.textAlignment = .left
        objLabel.lineBreakMode = .byWordWrapping
        objLabel.numberOfLines = 0
        return objLabel
    }()

    var stackData: UIStackView = {
        let knobsView = UIStackView()
        knobsView.frame = CGRect(x: 0, y: 36, width: 157, height: 107)
        knobsView.axis = .horizontal
        knobsView.distribution = .fillProportionally
        knobsView.spacing = 1
        knobsView.alignment = .fill
        knobsView.backgroundColor = .white
        return knobsView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(Label)
        addSubview(stackData)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
