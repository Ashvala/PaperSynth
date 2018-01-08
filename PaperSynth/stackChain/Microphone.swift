//
//  Microphone.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

class SCMic: SCUnit {

    var mic: AKMicrophone
    required init() {
        mic = AKMicrophone()
        mic.volume = 0.5
    }

    func getNode() -> AKNode {
        return mic as AKNode
    }

    func getUI() -> [PSRotaryKnob] {
        var knobs: [PSRotaryKnob] = []

        let volumeKnob = PSRotaryKnob(
            property: "Vol",
            value: mic.volume,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            self.mic.volume = sliderValue
        }
        knobs.append(volumeKnob)
        return knobs
    }
}
