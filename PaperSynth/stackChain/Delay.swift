//
//  Delay.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

/// Roughly the AKDelay Class. 
class SCDelay: SCUnit {
    let delay: Delay

    required init() {
        delay = Delay()
        delay.dryWetMix = 0.66
    }
    
    /**
     This function gets the AudioKit node object inside of a class.
     
     - returns
     `AKNode`
     */
    func getNode() -> Node {
        return delay as Node
    }

    func getUI() -> [PSRotaryKnob] {
        var knobs: [PSRotaryKnob] = []

        let mixKnob = PSRotaryKnob(
            property: "Mix",
            value: delay.dryWetMix,
            range: 0.0 ... 1.0,
            format: "%f Hz") { sliderValue in
            self.delay.dryWetMix = sliderValue
        }

        let timeKnob = PSRotaryKnob(
            property: "Time",
            value: delay.time,
            range: 1 ... 4,
            format: "%f") { sliderValue in
            self.delay.time = sliderValue
        }

        let feedBackKnob = PSRotaryKnob(
            property: "Fdbk",
            value: delay.feedback,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            self.delay.feedback = sliderValue
        }

        knobs.append(mixKnob)
        knobs.append(timeKnob)
        knobs.append(feedBackKnob)
        return knobs
        return knobs
    }
}
