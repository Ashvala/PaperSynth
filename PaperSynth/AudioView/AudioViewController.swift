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
import SwiftUI

class AudioViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
    UIViewControllerPreviewingDelegate {

    // MARK: Mutables
    
    var widgetList: [String]!
    @IBOutlet var synthStack: UILabel!
    var objList: [stackChainUnit]!
    var configured: Bool = false
    
    // MARK: Immutables
    
    let stackchainInstance: StackChain = StackChain()
    let engine = AudioEngine()

    let cellIdentifier = "MyCell"

    /// configure the audioview here.
    func configure(widgetNames: [String]) {
        widgetList = widgetNames
        objList = stackchainInstance.createObjects(widgetList: widgetList)
        configured = true
    }

    // MARK: Lifecycle methods
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
            let mixer = stackchainInstance.compileModel(nodesList: objList)
            engine.output = mixer
            do {
                try engine.start()
            } catch {
                print("Error starting engine")
            }

            view.addSubview(myCollectionView)
        }
    }

    override func viewDidAppear(_: Bool) {
        super.viewWillAppear(true)
        print("view appeared!")
        print("Got Object List \(objList)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: CollectionView delegate methods
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as? AudioBubble else { return UICollectionViewCell() }

        myCell.backgroundColor = UIColor(white: 0, alpha: 0.5)

        myCell.contentView.isUserInteractionEnabled = true

        let bounds = myCell.bounds
        myCell.label.text = widgetList[indexPath.row]
        myCell.layer.cornerRadius = bounds.width * 0.1
        print(indexPath.row)
        
        let knobs = objList[indexPath.row]
        print(knobs.name)
        myCell.embed(in: self, withParams: knobs.getParams())

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

    // MARK: Preview Context delegate methods	
    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation _: CGPoint) -> UIViewController? {
        return UIViewController()
    }

    func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {

        print("More FORCE!")
    }
}
