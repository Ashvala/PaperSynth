//
//  Oscillator.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import AudioKitUI
import SoundpipeAudioKit
import Foundation
import Controls
import SwiftUI

/// Roughly the AKOscillator Class. 
class Oscil {
    public let oscil: Oscillator
    public var freq:Float
    public var amp: Float
    

    init(initializedNode:Oscillator) {
        oscil = initializedNode
        freq = 880.0
        amp = 0.5
    }
    
    func makeBindingFreq(_ freq:Float) -> Binding<Float> {
        let frequency = self.freq
        return .init(
            get: {self.freq},
            set: {self.freq = $0}
        )
    }
    
    func makeBindingAmp(_ Amp:Float) -> Binding<Float> {
        let amplitude = self.amp
        return .init(
            get: {self.amp},
            set: {self.amp = $0}
        )
    }
    
    /**
     This method gets the AudioKit node object inside of a class.
     
     - returns
     `AKNode`
     */
    func getNode() -> Node {
        return oscil as Node
    }
    
    /**
     This method creates the rotary knobs required for this stackChain Unit
     
     - returns
         2 knobs: `freqKnob` and `ampKnob`.
         
         `freqKnob` handles the frequency of the oscillator and the `ampKnob` handles the amplitude.
     */

    func getUI() -> [ArcKnob] {
        let freqKnob = ArcKnob("Freq", value: makeBindingFreq(freq), range: 0.0...20000.0)
        let ampKnob = ArcKnob("Amp", value: makeBindingAmp(amp), range: 0.0...1.0)
        return [freqKnob, ampKnob]
    }
}
