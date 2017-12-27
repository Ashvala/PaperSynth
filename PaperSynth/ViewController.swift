//
//  ViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/8/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Storyboard Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detectedText: UILabel!
    @IBOutlet weak var imageButt: UIButton!
    let photoOutput = AVCapturePhotoOutput()
    
    // Mutables
    
    var model: VNCoreMLModel!
    var textMetadata = [Int: [Int: String]]()
    
    //Immutables
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLiveVideo()
        loadModel()
//        self.showImagePicker(withType: .camera)
        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTapRecognizer)
        
//        activityIndicator.hidesWhenStopped = true
    }
    
    private func loadModel() {
        model = try? VNCoreMLModel(for: chars74k5().model)
    }
    
    func createAlertController(title: String?, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    func createActionSheet() -> UIAlertController {
        return UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    }
    
    func createAction(title: String, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
    
    func addActionsToAlertController(controller: UIAlertController, actions: [UIAlertAction]) {
        for action in actions {
            controller.addAction(action)
        }
    }
    func startLiveVideo() {
        // this generates the session
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        //IO
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        //render this out.
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.videoGravity = .resizeAspectFill
        imageLayer.connection?.videoOrientation = .portrait
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            print("Could not add photo output to the session")
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
        session.startRunning()
    }
    
    @objc func handleTap(){
        print("tapped!")
        let components = self.detectedText.text!.components(separatedBy: " ")
        print("Components: \(components)")
        let filteredComponents = components.filter{$0 != ""}
        let parsedWords = filteredComponents.map{
            TextCleaner(text:$0).ReturnLevens()
        }
        print(parsedWords)
        self.detectedText.text = parsedWords.joined(separator: " ")
        let view = AudioView(widgetNames: parsedWords)
        let nV = view.renderView()
        self.view.addSubview(nV)
    }
    
    
    @IBAction func pickImageClicked(_ sender: UIButton) {
//        self.showImagePicker(withType: .camera)
        print("save the contents of ImageView to UIImage and process")
        // Of course, it won't be ruddy trivial, now will it?
        clearOldData()
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true    
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    
    }
    
    @IBAction func galleryImageClicked(_ sender: Any) {
        self.showImagePicker(withType: .photoLibrary)
    }
    
    
    func showImagePicker(withType type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true)
//        self.imageButt.isHidden = true
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Couldn't load image")
        }
        let newImage = fixOrientation(image: image)
        self.imageView.image = newImage
        clearOldData()
        showActivityIndicator()
        DispatchQueue.global(qos: .userInteractive).async {
            self.detectText(image: newImage)
        }
    }
    
    
    // MARK: text detection
    
    func detectText(image: UIImage) {
        let convertedImage = image |> adjustColors |> convertToGrayscale
        let handler = VNImageRequestHandler(cgImage: convertedImage.cgImage!)
        let request: VNDetectTextRectanglesRequest =
            VNDetectTextRectanglesRequest(completionHandler: { [unowned self] (request, error) in
                if (error != nil) {
                    print("Got Error In Run Text Dectect Request :(")
                } else {
                    guard let results = request.results as? Array<VNTextObservation> else {
                        fatalError("Unexpected result type from VNDetectTextRectanglesRequest")
                    }
                    if (results.count == 0) {
                        self.handleEmptyResults()
                        return
                    }
                    var numberOfWords = 0
                    for textObservation in results {
                        var numberOfCharacters = 0
                        for rectangleObservation in textObservation.characterBoxes! {
                            let croppedImage = crop(image: image, rectangle: rectangleObservation)
                            if let croppedImage = croppedImage {
                                let processedImage = preProcess(image: croppedImage)
                                self.classifyImage(image: processedImage,
                                                   wordNumber: numberOfWords,
                                                   characterNumber: numberOfCharacters)
                                numberOfCharacters += 1
                            }
                        }
                        numberOfWords += 1
                    }
                }
            })
        request.reportCharacterBoxes = true
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    func handleEmptyResults() {
        DispatchQueue.main.async {
            self.detectedText.text = "The image does not contain any text."
        }
        
    }
    
    func classifyImage(image: UIImage, wordNumber: Int, characterNumber: Int) {
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
            }
            let result = topResult.identifier
            print(result)
            let classificationInfo: [String: Any] = ["wordNumber" : wordNumber,
                                                     "characterNumber" : characterNumber,
                                                     "class" : result]
            self?.handleResult(classificationInfo)
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage :(")
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
        }
    }
    
    func handleResult(_ result: [String: Any]) {
        objc_sync_enter(self)
        guard let wordNumber = result["wordNumber"] as? Int else {
            return
        }
        guard let characterNumber = result["characterNumber"] as? Int else {
            return
        }
        guard let characterClass = result["class"] as? String else {
            return
        }
        if (textMetadata[wordNumber] == nil) {
            let tmp: [Int: String] = [characterNumber: characterClass]
            textMetadata[wordNumber] = tmp
        } else {
            var tmp = textMetadata[wordNumber]!
            tmp[characterNumber] = characterClass
            textMetadata[wordNumber] = tmp
        }
        objc_sync_exit(self)
        DispatchQueue.main.async {
            self.showDetectedText()
        }
    }
    
    func showDetectedText() {
        var result: String = ""
        if (textMetadata.isEmpty) {
            detectedText.text = "The image does not contain any text."
            return
        }
        let sortedKeys = textMetadata.keys.sorted()
        for sortedKey in sortedKeys {
            result +=  word(fromDictionary: textMetadata[sortedKey]!) + " "
        }
        detectedText.text = result
    }
    
    func word(fromDictionary dictionary: [Int : String]) -> String {
        let sortedKeys = dictionary.keys.sorted()
        var word: String = ""
        for sortedKey in sortedKeys {
            let char: String = dictionary[sortedKey]!
            word += char
        }
        return word
    }
    private func clearOldData() {
        detectedText.text = ""
        textMetadata = [:]
    }
    
    private func showActivityIndicator() {
    }
    
    private func hideActivityIndicator() {
    }

    func configureButton()
    {
        imageButt.layer.cornerRadius = 0.4 * imageButt.bounds.size.width
        imageButt.clipsToBounds = true
    }
    override func viewDidLayoutSubviews() {
        configureButton()
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        var requestOptions:[VNImageOption : Any] = [:]
        
        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics:camData]
        }
        
    }
    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        print("yay?!?!?!")
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            print("ok, should be here?")
//            if let sampleBuffer = photoSampleBuffer,
//                let previewBuffer = previewPhotoSampleBuffer,
//                let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer)
//            {
//                print("We made it this far?!")
//                if let image = UIImage(data: dataImage) {
//                    print("Yay?")
//                    DispatchQueue.global(qos: .userInteractive).async {
//                        self.detectText(image: image)
//                    }
//                }
//            }
            let sampleBuffer = photoSampleBuffer
            if sampleBuffer != nil{
                let ImageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
                let dataProvider = CGDataProvider(data: ImageData! as CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                let image = UIImage.init(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                let newImage = fixOrientation(image: image)
                DispatchQueue.global(qos: .userInteractive).async {
                UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
                        self.detectText(image: newImage)
                    
                }
            }
        }
    }

}

