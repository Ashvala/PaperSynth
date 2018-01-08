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
}

enum Types: String {
    case oscil = "SCOscil"
    case mic = "SCMic"
    case delay = "SCDelay"
    case mixer = "SCMixer"
    
    var getClass: AnyClass{
        return NSClassFromString(self.rawValue)!
    }
}

struct stackChainUnit {

    var name: String
    var type: Types
    var unitClass: AnyClass!

    init(name: String, type: Types) {
        self.name = name
        self.type = type
        self.unitClass = self.type.getClass
    }

}
