import AudioKit
import AudioKitUI
import Foundation
import UIKit

class AudioView {

    var widgetList: [String]
    var objList: [AnyObject]

    init(widgetNames: [String]) {
        widgetList = widgetNames
        objList = StackChain().createObjects(widgetList: widgetList)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func renderView() -> UIView {
        StackChain().compileModel(nodesList: objList)
        let view_size = UIScreen.main.bounds
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view_size.width, height: view_size.height))
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
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
        if type(of: objList[0]) == AKOscillator.self {
//            let returnedView = AudioBubble().oscBubble(oscil: objList[0] as! AKOscillator)
//            returnedView.frame.size.width = 157
//            returnedView.frame.size.height = 157
//            stackView.addArrangedSubview(returnedView)
        }

        // Microphone
        if type(of: objList[0]) == AKMicrophone.self {
            let Label = UILabel()
            Label.text = "Microphone Input"
            Label.font = UIFont(name: "Avenir", size: 14.0)
            stackView.addArrangedSubview(Label)
            Label.textColor = .white
        }
        view.addSubview(stackView)
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true

        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
