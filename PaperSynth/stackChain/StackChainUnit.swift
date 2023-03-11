//
//  StackChainUnit.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 1/4/18.
//  Copyright © 2018 Ashvala Vinay. All rights reserved.
//

import AudioKit
import Foundation
import SoundpipeAudioKit
import Controls
import UIKit
import SwiftUI



/// All available types go here. So, if you want to create a new unit, you add it here and create the binding. 
enum Sources:String{
    case oscil
    case fmoscil
    case pinknoise
    case noise
    func getObject() -> Node{
        switch self{
            case .oscil:
                return Oscillator()
            case .fmoscil:
                return FMOscillator()
            case .pinknoise:
                return PinkNoise()
            case .noise:
                return WhiteNoise()
        }
    }
}

enum Effects:String{
    case delay
    case hpfilter
    case lpfilter
    case reverb
    func getObject(inputNode:Node) -> Node{
        switch self{
            case .delay:
                return Delay(inputNode)
            case .hpfilter:
                    return HighPassFilter(inputNode)
            case .lpfilter:
                    return LowPassFilter(inputNode)
            case .reverb:
                return CostelloReverb(inputNode)
        }
    }
}

enum NodeType{
    case oscil
    case fmoscil
    case pinknoise
    case noise
    case delay
    case hpfilter
    case lpfilter
    case reverb
    func getObject(inputNode:Node? = nil) -> Node{
        switch self{
            case .oscil:
                return Oscillator()
            case .fmoscil:
                return FMOscillator()
            case .pinknoise:
                return PinkNoise()
            case .noise:
                return WhiteNoise()
            case .delay:
                return Delay(inputNode!)
            case .hpfilter:
                return HighPassFilter(inputNode!)
            case .lpfilter:
                return LowPassFilter(inputNode!)
            case .reverb:
                return CostelloReverb(inputNode!)
        }
    }

}

// create a factory function that generates either a source or effect from a string. If it's an effect, require an input node

func makeNode(data: String, inputNode: Node? = nil) -> Node{
    if let source = Sources(rawValue: data){
        return source.getObject()
    }
    else if let effect = Effects(rawValue: data){
        return effect.getObject(inputNode: inputNode!)
    }
    else{
        fatalError("Invalid node type")
    }
}

struct Parameter {
    let parameter: NodeParameter
    var value: Float
    let displayName: String
}



func extractParams(node: Node?) -> [Parameter]{
    var params: [Parameter] = []
    for param in (node as Node!).parameters{
        params.append(Parameter(parameter: param, value: Float(param.value), displayName: param.parameter.displayName))
    }
    return params
}

class stackChainUnit: ObservableObject{
    
    @Published public var name: String
    @Published public var type: NodeType
    @Published private var inputNode: Node?
    public let canInput: Bool
    public let canOutput: Bool
    @Published public var node: Node?
    @Published public var parameters: [Parameter] = [Parameter]()
    
    
    init(name: String, type: NodeType, inputNode: Node? = nil, canInput: Bool = false, canOutput: Bool = true){
        self.name = name
        self.type = type
        self.inputNode = inputNode
        self.canInput = canInput
        self.canOutput = canOutput
        
    }

    func getName() -> String{
        return name
    }

    func getType() -> NodeType{
        return type
    }

    func createNode() -> Node{
        return type.getObject(inputNode: inputNode)
    }

    func setInputNode(inputNode: Node){
        self.inputNode = inputNode
    }

    func setNode(settingNode: Node){
        self.node = settingNode
        self.parameters = extractParams(node: settingNode)
    }

    func makeBindingParams(param: Parameter) -> Binding<Float> {
        var value = param.value
        return .init(
            get: {value},
            set: {value = $0}
        )
    }

    func getParams() -> [Parameter]{
        print(self.parameters)
        return self.parameters
    }

        
}





