import AudioKit
import AudioKitUI
import Foundation
import UIKit

class AudioView {

    var widgetList: [String]
    var obj_list: [AnyObject]
    let Triangle = AKTable(.triangle)
    let Square = AKTable(.square)
    let sawtooth = AKTable(.sawtooth)
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

    func createObjects() {
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
        obj_list = NodesList
    }

    func compileModel() {
        obj_list.append(AKMixer())
        for (index, element) in obj_list.enumerated() {
            if index + 1 != obj_list.count {
                print("connecting \(index) to \(index + 1)")
                print("elements involved are: \(element), \(obj_list[index + 1])")
                (element as! AKNode).setOutput(to: obj_list[index + 1] as! AKInput)
            }
        }
        let generator = (obj_list[0] as! AKToggleable)
        let f_mixer = (obj_list[self.obj_list.count - 1] as! AKMixer)
        f_mixer.volume = 0.7
        AKSettings.audioInputEnabled = true
        AKSettings.useBluetooth = true
        AudioKit.output = f_mixer
        AudioKit.start()
        generator.start()
    }

  
    init(widgetNames: [String]) {
        widgetList = widgetNames
        obj_list = []
    }

    func renderView() -> UIView {
        let view_size = UIScreen.main.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view_size.width, height: view_size.height))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        createObjects()
        compileModel()
        setupUI(view: view)
        return view
    }

    func setupUI(view: UIView) {
        // Create a stack view.

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10

        // Create title label, which contains the signal path.
        let titleLabel = UILabel()
        titleLabel.text = widgetList.joined(separator: "->")
        titleLabel.font = UIFont(name: "Menlo", size: 18.0)
        titleLabel.textColor = .white
        stackView.addArrangedSubview(titleLabel)

        // Oscillator
        if type(of: obj_list[0]) == AKOscillator.self {
            let Label = UILabel()
            Label.text = "Oscillator"
            Label.font = UIFont(name: "Avenir", size: 14.0)
            stackView.addArrangedSubview(Label)
            Label.textColor = .white
            let oscil = obj_list[0] as! AKOscillator

            stackView.addArrangedSubview(AKSlider(
                property: "Frequency",
                value: oscil.frequency,
                range: 220.0 ... 2200.0,
                format: "%f Hz") { sliderValue in
                oscil.frequency = sliderValue
            })
            stackView.addArrangedSubview(AKSlider(
                property: "Amplitude",
                value: oscil.amplitude,
                range: 0.0 ... 1.0,
                format: "%f Hz") { sliderValue in
                oscil.amplitude = sliderValue
            })
        }

        // Microphone
        if type(of: obj_list[0]) == AKMicrophone.self {
            let Label = UILabel()
            Label.text = "Microphone Input"
            Label.font = UIFont(name: "Avenir", size: 14.0)
            stackView.addArrangedSubview(Label)
            Label.textColor = .white
        }

        for i in 1 ... (obj_list.count - 1) {
            let curr_obj = obj_list[i]

            if type(of: curr_obj) == AKEqualizerFilter.self {
                let Label = UILabel()
                Label.text = "Equalizer"
                Label.font = UIFont(name: "Avenir", size: 14.0)
                Label.textColor = .white
                stackView.addArrangedSubview(Label)
                let nstackView = UIStackView()
                nstackView.axis = .horizontal
                nstackView.distribution = .fillEqually
                nstackView.alignment = .fill
                nstackView.translatesAutoresizingMaskIntoConstraints = false
                nstackView.spacing = 10

                let eq_obj = (curr_obj as! AKEqualizerFilter)
                nstackView.addArrangedSubview(AKRotaryKnob(
                    property: "Frequency",
                    value: eq_obj.centerFrequency,
                    range: 20.0 ... 22000.0,
                    format: "%f Hz") { rotaryValue in
                    eq_obj.centerFrequency = rotaryValue
                })
                nstackView.addArrangedSubview(AKRotaryKnob(
                    property: "Gain",
                    value: eq_obj.gain,
                    range: -12.0 ... 12.0,
                    format: "%f dB") { rotaryValue in
                    eq_obj.gain = rotaryValue
                })
                nstackView.addArrangedSubview(AKRotaryKnob(
                    property: "Bandwidth",
                    value: eq_obj.bandwidth,
                    range: 10.0 ... 100.0,
                    format: "%f") { rotaryValue in
                    eq_obj.bandwidth = rotaryValue
                })
                stackView.addArrangedSubview(nstackView)
            }

            if type(of: curr_obj) == AKDelay.self {
                let Label = UILabel()
                Label.text = "Delay"
                Label.font = UIFont(name: "Avenir", size: 13.0)
                Label.textColor = .white
                let nstackView = UIStackView()
                nstackView.axis = .horizontal
                nstackView.distribution = .fillEqually
                nstackView.alignment = .fill
                nstackView.translatesAutoresizingMaskIntoConstraints = false
                nstackView.spacing = 10
                nstackView.addArrangedSubview(Label)
                let delay_obj = (curr_obj as! AKDelay)
                nstackView.addArrangedSubview(AKRotaryKnob(
                    property: "Mix",
                    value: delay_obj.dryWetMix,
                    range: 0.0 ... 1.0,
                    format: "%f%") { rotaryValue in
                    delay_obj.dryWetMix = rotaryValue
                })
                nstackView.addArrangedSubview(AKRotaryKnob(
                    property: "Time",
                    value: delay_obj.time,
                    range: 1 ... 1.5,
                    format: "%f seconds") { rotaryValue in
                    delay_obj.time = rotaryValue
                })
                stackView.addArrangedSubview(nstackView)
            }

            if type(of: curr_obj) == AKCostelloReverb.self {
                let Label = UILabel()
                Label.text = "Reverb"
                Label.font = UIFont(name: "Avenir", size: 14.0)
                Label.textColor = .white
                stackView.addArrangedSubview(Label)
                let reverb_obj = (curr_obj as! AKCostelloReverb)
                stackView.addArrangedSubview(AKSlider(
                    property: "Cutoff",
                    value: reverb_obj.cutoffFrequency,
                    range: 0.0 ... 22000.0,
                    format: "%f Hz") { rotaryValue in
                    reverb_obj.cutoffFrequency = rotaryValue
                })
                stackView.addArrangedSubview(AKRotaryKnob(
                    property: "Feedback",
                    value: reverb_obj.feedback,
                    range: 0.0 ... 1.0,
                    format: "%f percent") { rotaryValue in
                    reverb_obj.feedback = rotaryValue
                })
            }
        }

        view.addSubview(stackView)
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true

        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
