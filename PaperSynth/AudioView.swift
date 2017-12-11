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
import AudioKitUI



class AudioView{
    var widgetList:[String]
    var obj_list:[AnyObject]
    
    func constructOscil()->AKOscillator{
        let oscil = AKOscillator()
        oscil.frequency = 440.0
        oscil.amplitude = 1.0
        return oscil
    }
    
    func constructMic()->AKMicrophone{
        let microphone = AKMicrophone()
        return microphone
    }
    
    func constructADSR()->AKAmplitudeEnvelope{
        let ADSR  = AKAmplitudeEnvelope()
        ADSR.attackDuration = 1
        ADSR.decayDuration = 0.1
        ADSR.sustainLevel = 0.1
        ADSR.releaseDuration = 100
        return ADSR
    }
    
    func constructDelay()->AKDelay{
        let delay = AKDelay()
        delay.dryWetMix = 0.66
        return delay
    }
    
    func constructReverb()->AKCostelloReverb{
        let reverb = AKCostelloReverb()
        reverb.feedback = 0.66
        return reverb
    }
    
    func constructParaEQ()->AKEqualizerFilter{
        let eq = AKEqualizerFilter()
        eq.centerFrequency = 300.0
        eq.gain = 2.0
        return eq
    }
    
    func createObjects(){
        // From this point onwards, we assume that the first point in any list is just a node and everything else is an output.
        var NodesList:[AnyObject] = []
        var osc_count = 0
        var adsr_count = 0
        var delay_count = 0
        var reverb_count = 0
        var mic_count = 0
        var eq_count = 0
        for i in self.widgetList{
            switch(i){
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
    
    func compileModel(){
        self.obj_list.append(AKMixer())
        for (index, element) in (self.obj_list.enumerated()){
            if (index + 1 != self.obj_list.count){
                print("connecting \(index) to \(index+1)")
                print("elements involved are: \(element), \(self.obj_list[index+1])")
                (element as! AKNode).setOutput(to:self.obj_list[index+1] as! AKInput)
            }
        }
        let generator = (self.obj_list[0] as! AKToggleable)
        let f_mixer = (self.obj_list[self.obj_list.count-1] as! AKMixer)
        f_mixer.volume = 0.7
        AKSettings.audioInputEnabled = true
        AKSettings.useBluetooth = true
        AudioKit.output = f_mixer
        AudioKit.start()
        generator.start()

        
    }
    
    
    init(widgetNames:[String]){
        self.widgetList = widgetNames
        self.obj_list = []
    }
    
    func renderView()-> UIView{
        let view_size = UIScreen.main.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view_size.width, height: view_size.height))
        view.backgroundColor = .black
        view.alpha = 0.9
        self.createObjects()
        self.compileModel()
        self.setupUI(view: view)
        return view
    }
    
    func setupUI(view: UIView){
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10

        let titleLabel = UILabel()
        titleLabel.text = widgetList.joined(separator: "->")
        titleLabel.font = UIFont(name: "Menlo", size: 18.0)
        titleLabel.textColor = .white
        stackView.addArrangedSubview(titleLabel)
        
        if (type(of: self.obj_list[0]) == AKOscillator.self){
            let Label = UILabel()
            Label.text = "Oscillator"
            Label.font = UIFont(name: "Avenir", size: 14.0)
            stackView.addArrangedSubview(Label)
            Label.textColor = .white
            let oscil = self.obj_list[0] as! AKOscillator
            stackView.addArrangedSubview(AKSlider(
                property: "Frequency",
                value: oscil.frequency,
                range: 220.0...2200.0,
                format: "%f Hz") { sliderValue in
                    oscil.frequency = sliderValue
            })
        }
        
        if (type(of: self.obj_list[0]) == AKMicrophone.self){
            let Label = UILabel()
            Label.text = "Microphone Input"
            Label.font = UIFont(name: "Avenir", size: 14.0)
            stackView.addArrangedSubview(Label)
            Label.textColor = .white
        }
        
        for i in 1...(self.obj_list.count - 1){
            let curr_obj = self.obj_list[i]
            
            if (type(of:curr_obj) == AKEqualizerFilter.self){
                let Label = UILabel()
                Label.text = "Equalizer"
                Label.font = UIFont(name: "Avenir", size: 14.0)
                Label.textColor = .white
                stackView.addArrangedSubview(Label)
                let eq_obj = (curr_obj as! AKEqualizerFilter)
                stackView.addArrangedSubview(AKSlider(
                    property: "Center frequency",
                    value: eq_obj.centerFrequency,
                    range: 20.0...22000.0,
                    format:"%f Hz"){rotaryValue in
                        eq_obj.centerFrequency = rotaryValue
                })
                stackView.addArrangedSubview(AKSlider(
                    property: "gain",
                    value: eq_obj.gain,
                    range: -12.0...12.0,
                    format:"%f dB"){rotaryValue in
                        eq_obj.gain = rotaryValue
                })
                stackView.addArrangedSubview(AKSlider(
                    property: "Bandwidth",
                    value: eq_obj.bandwidth,
                    range: 10.0...100.0,
                    format:"%f"){rotaryValue in
                        eq_obj.bandwidth = rotaryValue
                })
            }
            
            if (type(of:curr_obj) == AKDelay.self){
                let Label = UILabel()
                Label.text = "Delay"
                Label.font = UIFont(name: "Avenir", size: 14.0)
                Label.textColor = .white
                stackView.addArrangedSubview(Label)
                let delay_obj = (curr_obj as! AKDelay)
                stackView.addArrangedSubview(AKRotaryKnob(
                    property: "delay mix",
                    value: delay_obj.dryWetMix,
                    range: 0.0...1.0,
                    format:"%f%"){rotaryValue in
                        delay_obj.dryWetMix = rotaryValue
                })
                stackView.addArrangedSubview(AKRotaryKnob(
                    property: "delayTime",
                    value: delay_obj.time,
                    range: 1...1.5,
                    format:"%f seconds"){rotaryValue in
                        delay_obj.time = rotaryValue
                })
            }
            
            if (type(of:curr_obj) == AKCostelloReverb.self){
                let Label = UILabel()
                Label.text = "Reverb"
                Label.font = UIFont(name: "Avenir", size: 14.0)
                Label.textColor = .white
                stackView.addArrangedSubview(Label)
                let reverb_obj = (curr_obj as! AKCostelloReverb)
                stackView.addArrangedSubview(AKSlider(
                    property: "Cutoff frequency",
                    value: reverb_obj.cutoffFrequency,
                    range: 0.0...22000.0,
                    format:"%f Hz"){rotaryValue in
                        reverb_obj.cutoffFrequency = rotaryValue
                })
                stackView.addArrangedSubview(AKRotaryKnob(
                    property: "Feedback",
                    value: reverb_obj.feedback,
                    range: 0.0...1.0,
                    format:"%f percent"){rotaryValue in
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
