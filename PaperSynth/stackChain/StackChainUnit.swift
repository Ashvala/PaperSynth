//
//  StackChainUnit.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

/// A simple stackchain unit should do the following: get a UI, have an initializer, and return the AKNode.
protocol SCUnit {
    func getUI() -> [PSRotaryKnob]
    init()
    func getNode() -> AKNode
}

/// All available types go here. So, if you want to create a new unit, you add it here and create the binding. 
enum Types {
    case oscil
    case mic
    case delay
    case mixer
    case reverb
    case eq
    func getObject() -> SCUnit {
        switch self {
        case .oscil:
            return SCOscil()
        case .mic:
            return SCMic()
        case .delay:
            return SCDelay()
        case .mixer:
            return SCMixer()
        case .reverb:
            return SCReverb()
        case .eq:
            return SCEqualizer()
        }
    }
}

/// A simple aliasing struct. Going forward, the name field and canInput fields will come in handy.

struct stackChainUnit {

    var name: String
    var type: Types
    var unit: SCUnit!
    var canInput: Bool

    init(name: String, type: Types, canInput: Bool) {
        self.name = name
        self.type = type
        self.canInput = canInput
        unit = self.type.getObject()
    }
}
