import AudioKit
import AudioKitUI
import Foundation
import UIKit

class StackChain {

    func constructOscil() -> AKOscillator {

        let oscil = AKOscillator()
        oscil.frequency = 440.0
        oscil.amplitude = 1.0
        return oscil
    }

    func constructMic() -> AKMicrophone {
        let microphone = AKMicrophone()
        return microphone
    }

    func constructADSR() -> AKAmplitudeEnvelope {
        let ADSR = AKAmplitudeEnvelope()
        ADSR.attackDuration = 1
        ADSR.decayDuration = 0.1
        ADSR.sustainLevel = 0.1
        ADSR.releaseDuration = 100
        return ADSR
    }

    func constructDelay() -> AKDelay {
        let delay = AKDelay()
        delay.dryWetMix = 0.66
        return delay
    }

    func constructReverb() -> AKCostelloReverb {
        let reverb = AKCostelloReverb()
        reverb.feedback = 0.66
        return reverb
    }

    func constructParaEQ() -> AKEqualizerFilter {
        let eq = AKEqualizerFilter()
        eq.centerFrequency = 300.0
        eq.gain = 2.0
        return eq
    }

    func createObjects(widgetList: [String]) -> [AnyObject] {
        // From this point onwards, we assume that the first point in any list is just a node and everything else is an output.
        var NodesList: [AnyObject] = []
        var osc_count = 0
        var adsr_count = 0
        var delay_count = 0
        var reverb_count = 0
        var mic_count = 0
        var eq_count = 0
        for i in widgetList {
            switch i {
            case "osc":
                NodesList.append(constructOscil())
                osc_count += 1
            case "adsr":
                NodesList.append(constructADSR())
                adsr_count += 1
            case "del":
                NodesList.append(constructDelay())
                delay_count += 1
            case "rev":
                NodesList.append(constructReverb())
                reverb_count += 1
            case "eq":
                NodesList.append(constructParaEQ())
                eq_count += 1
            case "mic":
                NodesList.append(constructMic())
                mic_count += 1
            default:
                print("Not appending this. Unrecognized keyword")
            }
        }
        return NodesList
    }

    func compileModel(NodesList: [AnyObject]) {
        var obj_list = NodesList
        obj_list.append(AKMixer())
        for (index, element) in obj_list.enumerated() {
            if index + 1 != obj_list.count {
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(obj_list[index + 1])")
                (element as! AKNode).setOutput(to: obj_list[index + 1] as! AKInput)
            }
        }
        let generator = (obj_list[0] as! AKToggleable)
        let f_mixer = (obj_list[obj_list.count - 1] as! AKMixer)
        f_mixer.volume = 0.8
        AKSettings.audioInputEnabled = true
        AKSettings.useBluetooth = true
        AudioKit.output = f_mixer
        AudioKit.start()
        generator.start()
    }
}
