//
//  PSMixer.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

/// Roughly the AKMixer Class. 
class SCMixer: SCUnit {
    let mixer: AKMixer

    required init() {
        mixer = AKMixer()
        mixer.volume = 0.66
    }
    
    /**
     This function gets the AudioKit node object inside of a class.
     
     - returns
     `AKNode`
     */
    func getNode() -> AKNode {
        return mixer as AKNode
    }

    func getUI() -> [PSRotaryKnob] {
        var knobs = [PSRotaryKnob]()

        let volumeKnob = PSRotaryKnob(
            property: "Vol",
            value: mixer.volume,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            self.mixer.volume = sliderValue
        }

        knobs.append(volumeKnob)
        return knobs
    }
}
