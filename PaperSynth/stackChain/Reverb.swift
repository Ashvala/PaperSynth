//
//  Reverb.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/8/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import SoundpipeAudioKit
import Foundation

/// Roughly the AKCostelloReverb Class. 
class SCReverb: SCUnit {
    var reverb: CostelloReverb
    required init() {
        reverb = CostelloReverb(none)
    }
    
    /**
     This function gets the AudioKit node object inside of a class.
     
     - returns
     `AKNode`
     */
    
    func getNode() -> Node {
        return reverb
    }
    
    /**
     This method creates the rotary knobs required for this stackChain Unit
     
     - returns
         2 knobs: `fdbkKnob` and `cutOffKnob`.
     
         `fdbkKnob` handles the feedback from the reverbarator and the `cutoffKnob` handles the low pass cutoff frequency.
     */
    func getUI() -> [PSRotaryKnob] {

        var knobs: [PSRotaryKnob] = []

        let fdbkKnob = PSRotaryKnob(
            property: "Fdbk",
            value: reverb.feedback,
            range: 0.0 ... 0.9,
            format: "%f") { sliderValue in
            self.reverb.feedback = sliderValue
        }

        let cutOffKnob = PSRotaryKnob(
            property: "Cutoff",
            value: reverb.cutoffFrequency,
            range: 0.0 ... 0.9,
            format: "%f") { sliderValue in
            self.reverb.cutoffFrequency = sliderValue
        }

        knobs.append(cutOffKnob)
        knobs.append(fdbkKnob)

        return knobs
    }
}
