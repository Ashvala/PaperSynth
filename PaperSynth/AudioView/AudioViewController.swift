//
//  AudioViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/28/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

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
            synthStack.text = widgetList.joined(separator: "->")
            synthStack.font = UIFont(name: "Menlo", size: 18.0)
            synthStack.textColor = .white

            // Background Blur!
            let blurEffect = UIBlurEffect(style: .regular)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = view.frame
            view.insertSubview(blurEffectView, at: 0)

            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 60, left: 10, bottom: 10, right: 10)
            layout.itemSize = CGSize(width: 157, height: 157)
            let myCollectionView: UICollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
            myCollectionView.dataSource = self
            myCollectionView.delegate = self
            myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
            myCollectionView.register(AudioBubble.self, forCellWithReuseIdentifier: cellIdentifier)
            myCollectionView.backgroundColor = .clear
            if traitCollection.forceTouchCapability == .available {

                registerForPreviewing(with: self, sourceView: view)
            }
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

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath as IndexPath) as! AudioBubble
        myCell.backgroundColor = UIColor(white: 0.1, alpha: 0.5)
        let bounds = myCell.bounds
        myCell.Label.text = "Label!"
        myCell.layer.cornerRadius = bounds.width * 0.1
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

    func previewingContext(_: UIViewControllerPreviewing, viewControllerForLocation _: CGPoint) -> UIViewController? {

        print("FORCEEEE")
        return UIViewController()
    }

    func previewingContext(_: UIViewControllerPreviewing, commit _: UIViewController) {

        print("More FORCE!")
    }
}
