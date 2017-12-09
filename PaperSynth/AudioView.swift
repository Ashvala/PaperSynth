//
//  AudioView.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/9/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation
import UIKit
import AudioKit

class AudioView{
    var widgetList:[String]
    func generateNodes() -> [AKNode]{
        var NodesList:[AKNode] = []
        for i in widgetList{
            switch(i){
                case "osc":
                    NodesList.append(createOscil())
                case "adsr":
                    NodesList.append(createEnvelope())
                case "delay":
                    NodesList.append(createDelay())
                default:
                    print("Not appending this. Unrecognized keyword")
            }
        }
        return NodesList
    }
    
    func LineChain(){
        
        
    }
    
    init(widgetNames:[String]){
        self.widgetList = widgetNames
    }
  
    func createOscil()->AKNode{
        let oscillator = AKOscillator()
        oscillator.amplitude = 0.6
        oscillator.frequency = 440.0
        return oscillator as AKNode
    }
    
    func createEnvelope()->AKNode{
        let env = AKAmplitudeEnvelope()
        
        return env as AKNode
    }
    
    func createDelay()->AKNode{
        let delay = AKDelay()
        delay.dryWetMix = 0.8
        return delay as AKNode
    }
    func renderView()-> UIView{
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let mixer = AKMixer()
        AudioKit.output = mixer
        AudioKit.start()
        
        return view
    }
    
}
