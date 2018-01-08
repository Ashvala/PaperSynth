//
//  StackChainUnit.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation

protocol SCUnit {
    func getUI() -> [PSRotaryKnob]
    init()
    func getNode() -> AKNode
}

extension SCUnit {
    func entity() -> Self {
        return Self()
    }
}

enum Types {
    case oscil
    case mic
    case delay
    case mixer
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
        }
    }
}

struct stackChainUnit {

    var name: String
    var type: Types
    var unitClass: SCUnit!
    var canInput: Bool

    init(name: String, type: Types, canInput: Bool) {
        self.name = name
        self.type = type
        self.unitClass = self.type.getObject()
        self.canInput = canInput
    }

}
