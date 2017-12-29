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

class AudioBubble {

    func oscBubble(oscil: AKOscillator) -> UIView {
        // Create View
        let view = UIView()
        // Create Label
        let Label = UILabel()
        Label.text = "Oscillator"

        // Create the stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        Label.font = UIFont(name: "Avenir", size: 14.0)
        Label.textColor = .white

        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.distribution = .fillEqually
        horizontalStack.alignment = .fill
        horizontalStack.translatesAutoresizingMaskIntoConstraints = true
        horizontalStack.addArrangedSubview(Label)
        let fKnob = AKRotaryKnob(
            property: "Freq",
            value: oscil.frequency,
            range: 220.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
            oscil.frequency = sliderValue
        }
        fKnob.knobBorderWidth = 2
        fKnob.indicatorColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)
        fKnob.knobBorderColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 1)
        fKnob.knobColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 0)
        fKnob.knobStyle = AKRotaryKnobStyle.round
        horizontalStack.addArrangedSubview(fKnob)
        view.addSubview(horizontalStack)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        return view
    }
}
