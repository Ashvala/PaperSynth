//
//  Oscillator.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import Foundation
import AudioKit
import AudioKitUI

class PSOscil {
    let oscil: AKOscillator
    
    init() {
        self.oscil = AKOscillator()
        self.oscil.frequency = 440.0
        self.oscil.amplitude = 0.5
    }
    
    func getUnit()-> AKOscillator{
        return self.oscil
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
            value: self.oscil.amplitude,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
                self.oscil.amplitude = sliderValue
        }
        
        knobs.append(freqKnob)
        knobs.append(ampKnob)
        return knobs
    }
    
}
