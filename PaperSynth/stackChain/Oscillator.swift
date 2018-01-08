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

class SCOscil: SCUnit {
    let oscil: AKOscillator

    init() {
        oscil = AKOscillator()
        oscil.frequency = 440.0
        oscil.amplitude = 0.5
    }

    func getUnit() -> AKOscillator {
        return oscil
    }

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
