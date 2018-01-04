import AudioKit
import AudioKitUI
import Foundation
import UIKit

class StackChain {

    func generateKnobs(oscil: AKOscillator) -> [PSRotaryKnob] {

        var knobs: [PSRotaryKnob] = []

        let freqKnob = PSRotaryKnob(
            property: "Freq",
            value: oscil.frequency,
            range: 220.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
            oscil.frequency = sliderValue
        }

        let ampKnob = PSRotaryKnob(
            property: "Amp",
            value: oscil.amplitude,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            oscil.amplitude = sliderValue
        }

        knobs.append(freqKnob)
        knobs.append(ampKnob)
        return knobs
    }

    func generateKnobs(delay: AKDelay) -> [PSRotaryKnob] {
        var knobs: [PSRotaryKnob] = []

        let mixKnob = PSRotaryKnob(
            property: "Mix",
            value: delay.dryWetMix,
            range: 0.0 ... 1.0,
            format: "%f Hz") { sliderValue in
            delay.dryWetMix = sliderValue
        }

        let timeKnob = PSRotaryKnob(
            property: "Time",
            value: delay.time,
            range: 1 ... 4,
            format: "%f") { sliderValue in
            delay.time = sliderValue
        }

        let feedBackKnob = PSRotaryKnob(
            property: "Fdbk",
            value: delay.feedback,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            delay.feedback = sliderValue
        }

        knobs.append(mixKnob)
        knobs.append(timeKnob)
        knobs.append(feedBackKnob)
        return knobs
    }

    func generateKnobs(reverb: AKCostelloReverb) -> [PSRotaryKnob] {

        var knobs: [PSRotaryKnob] = []

        let fdbkKnob = PSRotaryKnob(
            property: "Fdbk",
            value: reverb.feedback,
            range: 0.0 ... 0.9,
            format: "%f") { sliderValue in
            reverb.feedback = sliderValue
        }

        let cutOffKnob = PSRotaryKnob(
            property: "Cutoff",
            value: reverb.cutoffFrequency,
            range: 0.0 ... 0.9,
            format: "%f") { sliderValue in
            reverb.cutoffFrequency = sliderValue
        }

        knobs.append(cutOffKnob)
        knobs.append(fdbkKnob)

        return knobs
    }

    func generateKnobs(eq: AKEqualizerFilter) -> [PSRotaryKnob] {

        var knobs: [PSRotaryKnob] = []

        let freqKnob = PSRotaryKnob(
            property: "Freq",
            value: eq.centerFrequency,
            range: 20.0 ... 2200.0,
            format: "%f Hz") { sliderValue in
            eq.centerFrequency = sliderValue
        }

        let timeKnob = PSRotaryKnob(
            property: "Gain",
            value: eq.gain,
            range: 0.0 ... 1.0,
            format: "%f") { sliderValue in
            eq.gain = sliderValue
        }

        let feedBackKnob = PSRotaryKnob(
            property: "q",
            value: eq.bandwidth,
            range: 0.0 ... 5.0,
            format: "%f") { sliderValue in
            eq.bandwidth = sliderValue
        }

        knobs.append(freqKnob)
        knobs.append(timeKnob)
        knobs.append(feedBackKnob)

        return knobs
    }

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
        var nodesList: [AnyObject] = []
        var osc_count = 0
        var adsr_count = 0
        var delay_count = 0
        var reverb_count = 0
        var mic_count = 0
        var eq_count = 0
        for i in widgetList {
            switch i {
            case "osc":
                nodesList.append(constructOscil())
                osc_count += 1
            case "adsr":
                nodesList.append(constructADSR())
                adsr_count += 1
            case "del":
                nodesList.append(constructDelay())
                delay_count += 1
            case "rev":
                nodesList.append(constructReverb())
                reverb_count += 1
            case "eq":
                nodesList.append(constructParaEQ())
                eq_count += 1
            case "mic":
                nodesList.append(constructMic())
                mic_count += 1
            default:
                print("Not appending this. Unrecognized keyword")
            }
        }
        return nodesList
    }

    func compileModel(nodesList: [AnyObject]) {
        var objList = nodesList
        objList.append(AKMixer())
        for (index, element) in objList.enumerated() {
            if index + 1 != objList.count {
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(objList[index + 1])")
                (element as! AKNode).setOutput(to: objList[index + 1] as! AKInput)
            }
        }
        let generator = (objList[0] as! AKToggleable)
        let f_mixer = (objList[objList.count - 1] as! AKMixer)
        f_mixer.volume = 0.8
        AKSettings.audioInputEnabled = true
        AKSettings.useBluetooth = true
        AudioKit.output = f_mixer
        AudioKit.start()
        generator.start()
    }
}
