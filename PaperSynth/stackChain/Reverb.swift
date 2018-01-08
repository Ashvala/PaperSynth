//
//  Reverb.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/8/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

/// Roughly the AKCostelloReverb Class. 
class SCReverb: SCUnit {
    var reverb: AKCostelloReverb
    required init() {
        reverb = AKCostelloReverb()
    }

    func getNode() -> AKNode {
        return reverb
    }

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
