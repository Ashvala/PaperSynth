//
//  PSMixer.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import Foundation
import AudioKit

class PSMixer{
    let mixer: AKMixer
   
    init(){
        self.mixer = AKMixer()
        mixer.volume = 0.66
    }
    
    func getUnit()-> AKMixer{
        return self.mixer
    }
}
