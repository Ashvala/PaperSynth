//
//  equalizer.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/8/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

class SCEqualizer: SCUnit {
    let eq: AKEqualizerFilter
    required init() {
        eq = AKEqualizerFilter()
    }

    func getNode() -> AKNode {
        return eq
    }

    func getUI() -> [PSRotaryKnob] {
        var knobs: [PSRotaryKnob] = []

        let freqKnob = PSRotaryKnob(
            property: "Freq",
            value: eq.centerFrequency,
            range: 20.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
            self.eq.centerFrequency = sliderValue
        }

        let timeKnob = PSRotaryKnob(
            property: "Gain",
            value: eq.gain,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            self.eq.gain = sliderValue
        }

        let feedBackKnob = PSRotaryKnob(
            property: "q",
            value: eq.bandwidth,
            range: 0.0 ... 5.0,
            format: "%f") { sliderValue in
            self.eq.bandwidth = sliderValue
        }

        knobs.append(freqKnob)
        knobs.append(timeKnob)
        knobs.append(feedBackKnob)

        return knobs
    }
}
