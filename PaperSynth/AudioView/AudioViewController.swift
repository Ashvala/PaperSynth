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

class AudioViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    UIViewControllerPreviewingDelegate {

    var widgetList: [String]!
    @IBOutlet var synthStack: UILabel!
    var objList: [AnyObject]!
    var configured: Bool = false
    let stackchainInstance: StackChain = StackChain()

    let cellIdentifier = "MyCell"

    func configure(widgetNames: [String]) {
        widgetList = widgetNames
        objList = stackchainInstance.createObjects(widgetList: widgetList)
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
            stackchainInstance.compileModel(nodesList: objList)

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
        let operatingObject: AnyObject = forObject

        if type(of: operatingObject) == AKOscillator.self {

            print("Creating oscillator!")
            let oscil = operatingObject as! AKOscillator
            knobsView = stackchainInstance.generateKnobs(oscil: oscil)

        } else if type(of: operatingObject) == AKDelay.self {

            print("Creating Delay!")
            let delay = operatingObject as! AKDelay
            knobsView = stackchainInstance.generateKnobs(delay: delay)

        } else if type(of: operatingObject) == AKCostelloReverb.self {

            print("Creating Reverb!")
            let reverbObj = operatingObject as! AKCostelloReverb
            knobsView = stackchainInstance.generateKnobs(reverb: reverbObj)

        } else if type(of: operatingObject) == AKEqualizerFilter.self {

            print("Creating Reverb!")
            let eq = operatingObject as! AKEqualizerFilter
            knobsView = stackchainInstance.generateKnobs(eq: eq)
        }

        return knobsView
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as? AudioBubble else { return UICollectionViewCell() }

        myCell.backgroundColor = UIColor(white: 0, alpha: 0.5)

        myCell.contentView.isUserInteractionEnabled = true

        let bounds = myCell.bounds
        myCell.label.text = widgetList[indexPath.row]
        myCell.layer.cornerRadius = bounds.width * 0.1

        let knobs = (getKnobs(forObject: objList[indexPath.row]))

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
