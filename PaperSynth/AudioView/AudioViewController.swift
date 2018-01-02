//
//  AudioViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import Foundation
import UIKit
import AudioKitUI
import AudioKit

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
            StackChainInstance.compileModel(NodesList: self.obj_list)
            
            view.addSubview(myCollectionView)
        }
    }

    override func viewDidAppear(_: Bool) {
        super.viewWillAppear(true)
        print("yolo!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getKnobs(forObject: AnyObject) -> [PSRotaryKnob]{
        var knobsView: [PSRotaryKnob] = []
        let operatingObject = forObject
        if type(of: operatingObject) == AKOscillator.self{
            print("Creating oscillator!")
            let oscil = operatingObject as! AKOscillator
            
            let freqKnob = PSRotaryKnob(
                property: "Freq",
                value: oscil.frequency,
                range: 220.0 ... 2200.0,
                format: "%f Hz") { sliderValue in
                    oscil.frequency = sliderValue
            }
            
            freqKnob.knobBorderWidth = 1
            freqKnob.indicatorColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1)
            freqKnob.knobBorderColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1)
            freqKnob.knobColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 0)
            freqKnob.knobStyle = PSRotaryKnobStyle.round
            freqKnob.fontSize = 12.0
            let ampKnob = PSRotaryKnob(
                property: "Amp",
                value: oscil.amplitude,
                range: 0.0 ... 1.0,
                format: "%f") { sliderValue in
                    oscil.amplitude = sliderValue
            }
            
            ampKnob.knobBorderWidth = 1
            ampKnob.indicatorColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1)
            ampKnob.knobBorderColor = UIColor(red: 151 / 255.0, green: 151 / 255.0, blue: 151 / 255.0, alpha: 1)
            ampKnob.knobColor = UIColor(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 0)
            ampKnob.knobStyle = PSRotaryKnobStyle.round
            ampKnob.fontSize = 12.0
            knobsView.append(freqKnob)
            knobsView.append(ampKnob)

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
        
        let knobs = (self.getKnobs(forObject: self.obj_list[indexPath.row]))
        
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
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
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


