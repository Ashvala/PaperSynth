//
//  Oscillator.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import AudioKitUI
import Foundation

/// Roughly the AKOscillator Class. 
class SCOscil: SCUnit {
    let oscil: AKOscillator

    required init() {
        oscil = AKOscillator()
        oscil.frequency = 440.0
        oscil.amplitude = 0.5
    }
    
    /**
     This method gets the AudioKit node object inside of a class.
     
     - returns
     `AKNode`
     */
    func getNode() -> AKNode {
        return oscil as AKNode
    }
    
    /**
     This method creates the rotary knobs required for this stackChain Unit
     
     - returns
         2 knobs: `freqKnob` and `ampKnob`.
         
         `freqKnob` handles the frequency of the oscillator and the `ampKnob` handles the amplitude.
     */

    func getUI() -> [PSRotaryKnob] {
        var knobs: [PSRotaryKnob] = []

        let freqKnob = PSRotaryKnob(
            property: "Freq",
            value: oscil.frequency,
            range: 220.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
            self.oscil.frequency = sliderValue
        }

        let ampKnob = PSRotaryKnob(
            property: "Amp",
            value: oscil.amplitude,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            self.oscil.amplitude = sliderValue
        }

        knobs.append(freqKnob)
        knobs.append(ampKnob)
        return knobs
    }
}
