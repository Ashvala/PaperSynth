//
//  myKnob.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 3/10/23.
//  Copyright © 2023 Ashvala Vinay. All rights reserved.
//

import SwiftUI
import AudioKitUI
import Controls

struct myKnob: View{
    
    func makeBindingParams(param: Parameter) -> Binding<Float> {
        var value = param.value
        return .init(
            get: {value},
            set: {value = $0}
        )
    }
    
    let params: [Parameter]
    
    var body: some View {
        VStack {
            ForEach(params, id: \.displayName) { param in
                HStack {
                    ArcKnob("\(param.value)", value: self.makeBindingParams(param: param), range: param.parameter.range)
                }
            }
        }
    }
}

//struct myKnob_Previews: PreviewProvider {
//    static var previews: some View {
//        myKnob()
//    }
//}

