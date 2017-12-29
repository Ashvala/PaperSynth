//
//  AudioBubbles.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/29/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation
import UIKit
import AudioKit
import AudioKitUI


/**
 The audiobubble class handles construction of the control center-esque bubbles for controls
 */

class AudioBubble{
    
    func oscBubble(oscil: AKOscillator) -> UIView{
        let view = UIView()
        let Label = UILabel()
        Label.text = "Oscillator"
        var stackView = UIStackView()
        Label.font = UIFont(name: "Avenir", size: 14.0)
        Label.textColor = .white
        stackView.addArrangedSubview(Label)
        stackView.addArrangedSubview(AKSlider(
            property: "Frequency",
            value: oscil.frequency,
            range: 220.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
                oscil.frequency = sliderValue
        })
        stackView.addArrangedSubview(AKSlider(
            property: "Amplitude",
            value: oscil.amplitude,
            range: 0.0 ... 1.0,
            format: "%f Hz") { sliderValue in
                oscil.amplitude = sliderValue
        })
        view.addSubview(stackView)
        return view
    }
}
