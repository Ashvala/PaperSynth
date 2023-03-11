//
//  myKnob.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 3/10/23.
//  Copyright © 2023 Ashvala Vinay. All rights reserved.
//
import AudioKit
import AVFoundation
import SwiftUI
import AudioKitUI
import Controls

struct myKnobs: View{
    
    func makeBindingParams(param: Parameter) -> Binding<Float> {
        return .init(
            get: {self.node.parameters.first(where: {$0.parameter.displayName == param.displayName})?.parameter.value ?? 0.0},
            set: {(newValue) in
                for i in self.node.parameters{
                    if i.parameter.displayName == param.displayName {
                        i.parameter.value = AUValue(newValue)
                    }
                }
            }
        )
    }

    var params: [Parameter]
    var node: Node
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: [.init(.adaptive(minimum: 45, maximum: 50), alignment: .top)]) {
                ForEach(params, id: \.displayName) { param in
                    VStack{
                        ArcKnob("\(param.value)", value: self.makeBindingParams(param: param), range: param.parameter.range).foregroundColor(.white)
                    }
                    
                }.scaledToFit()
            
        }
    }
}

