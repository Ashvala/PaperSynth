//
//  AudioViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import AudioKit
import AudioKitUI
import Foundation
import UIKit

class AudioViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerPreviewingDelegate {

    var widgetList: [String]!
    @IBOutlet var synthStack: UILabel!
    var obj_list: [AnyObject]!
    var configured: Bool = false
    let StackChainInstance: StackChain = StackChain()

    let cellIdentifier = "MyCell"

    func configure(widgetNames: [String]) {
        widgetList = widgetNames
        obj_list = StackChainInstance.createObjects(widgetList: widgetList)
        configured = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if configured == false {
            fatalError("Please Configure first!")
        } else {
            print("loaded!")
            synthStack.text = widgetList.joined(separator: " -> ")
            synthStack.font = UIFont(name: "Menlo", size: 18.0)
            synthStack.textColor = .white

            // Background Blur!
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.frame
            view.insertSubview(blurEffectView, at: 0)

            // Create the collection view
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 60, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: 157, height: 157)
            let myCollectionView: UICollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
            myCollectionView.delaysContentTouches = false
            myCollectionView.dataSource = self

            myCollectionView.delegate = self
            myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
            myCollectionView.register(AudioBubble.self, forCellWithReuseIdentifier: cellIdentifier)
            myCollectionView.backgroundColor = .clear

            // Force Touch handlers.
            if traitCollection.forceTouchCapability == .available {
                registerForPreviewing(with: self, sourceView: view)
            }
            StackChainInstance.compileModel(NodesList: obj_list)

            view.addSubview(myCollectionView)
        }
    }

    override func viewDidAppear(_: Bool) {
        super.viewWillAppear(true)
        print("view appeared!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Needs to be refactored.

    func getKnobs(forObject: AnyObject) -> [PSRotaryKnob] {
        var knobsView: [PSRotaryKnob] = []

        let operatingObject = forObject
        if type(of: operatingObject) == AKOscillator.self {
            print("Creating oscillator!")
            let oscil = operatingObject as! AKOscillator

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

            knobsView.append(freqKnob)
            knobsView.append(ampKnob)

        } else if type(of: operatingObject) == AKDelay.self {

            print("Creating Delay!")
            let delayed = operatingObject as! AKDelay

            let mixKnob = PSRotaryKnob(
                property: "Mix",
                value: delayed.dryWetMix,
                range: 0.0 ... 1.0,
                format: "%f Hz") { sliderValue in
                delayed.dryWetMix = sliderValue
            }

            let timeKnob = PSRotaryKnob(
                property: "Time",
                value: delayed.time,
                range: 1 ... 4,
                format: "%f") { sliderValue in
                delayed.time = sliderValue
            }

            let feedBackKnob = PSRotaryKnob(
                property: "Fdbk",
                value: delayed.feedback,
                range: 0.0 ... 1.0,
                format: "%f") { sliderValue in
                delayed.feedback = sliderValue
            }

            knobsView.append(mixKnob)
            knobsView.append(feedBackKnob)
            knobsView.append(timeKnob)

        } else if type(of: operatingObject) == AKCostelloReverb.self {
            print("Creating Reverb!")
            let reverbObj = operatingObject as! AKCostelloReverb

            let fdbkKnob = PSRotaryKnob(
                property: "Fdbk",
                value: reverbObj.feedback,
                range: 0.0 ... 0.9,
                format: "%f") { sliderValue in
                reverbObj.feedback = sliderValue
            }

            let cutOffKnob = PSRotaryKnob(
                property: "Cutoff",
                value: reverbObj.cutoffFrequency,
                range: 0.0 ... 0.9,
                format: "%f") { sliderValue in
                reverbObj.cutoffFrequency = sliderValue
            }

            knobsView.append(fdbkKnob)
            knobsView.append(cutOffKnob)

        } else if type(of: operatingObject) == AKEqualizerFilter.self {
            print("Creating Reverb!")
            let eq = operatingObject as! AKEqualizerFilter

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

            knobsView.append(freqKnob)
            knobsView.append(feedBackKnob)
            knobsView.append(timeKnob)
        }

        return knobsView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! AudioBubble

        myCell.backgroundColor = UIColor(white: 0, alpha: 0.5)

        myCell.contentView.isUserInteractionEnabled = true

        let bounds = myCell.bounds
        myCell.Label.text = widgetList[indexPath.row]
        myCell.layer.cornerRadius = bounds.width * 0.1

        let knobs = (getKnobs(forObject: obj_list[indexPath.row]))

        knobs.forEach({
            myCell.stackData.addArrangedSubview($0)
        })
        return myCell
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return widgetList.count
    }

    private func collectionView(collectionView _: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        print("User tapped on item \(indexPath.row)")
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }

    func collectionView(_: UICollectionView, shouldSelectItemAt _: IndexPath) -> Bool {
        return false
    }

    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation _: CGPoint) -> UIViewController? {

        print("FORCEEEE")
        return UIViewController()
    }

    func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {

        print("More FORCE!")
    }
}
