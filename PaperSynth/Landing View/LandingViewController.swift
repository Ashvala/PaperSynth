//
//  ViewController.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/8/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//

import AVFoundation
import CoreML
import Photos
import UIKit
import Vision

class LandingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func configureButton() {
        imageButt.layer.cornerRadius = 0.5 * imageButt.bounds.size.width
        imageButt.layer.masksToBounds = true
        imageButt.clipsToBounds = true
    }

    override func viewDidLayoutSubviews() {
        configureButton()
    }

    // MARK: Storyboard Outlets

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var detectedText: UILabel!
    @IBOutlet var imageButt: UIButton!
    @IBOutlet var lastGallImage: UIImageView!

    // MARK: Mutables

    var model: VNCoreMLModel!
    var textMetadata = [Int: [Int: String]]()
    var showing = false

    // MARK: Immutables

    let photoOutput = AVCapturePhotoOutput()
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        startLiveVideo()
        loadModel()

        // set last image:
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        let last = fetchResult.lastObject

        if let lastAsset = last {
            let options = PHImageRequestOptions()
            options.version = .current

            PHImageManager.default().requestImage(
                for: lastAsset,
                targetSize: lastGallImage.bounds.size,
                contentMode: .aspectFit,
                options: options,
                resultHandler: { image, _ in
                    self.lastGallImage.image = image
                }
            )
        }
        // Add a two finger tap recognizer to run when you are ready to roll.

        let twoFingerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        twoFingerTapRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(twoFingerTapRecognizer)
    }

    /**
     Load a core ML Model
     */

    private func loadModel() {
        model = try? VNCoreMLModel(for: chars74k5().model)
    }

    /**

     Configure session!

     */
    func startLiveVideo() {
        // this generates the session
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        // IO
        if captureDevice != nil {
            let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
            let deviceOutput = AVCaptureVideoDataOutput()
            deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
            session.addInput(deviceInput)
            session.addOutput(deviceOutput)

            // render this out.
            let imageLayer = AVCaptureVideoPreviewLayer(session: session)
            imageLayer.videoGravity = .resizeAspectFill
            imageLayer.connection?.videoOrientation = .portrait
            imageLayer.frame = imageView.bounds
            imageView.layer.addSublayer(imageLayer)

            // Add an output. Like, a photo output?

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

        } else {
            return
        }
    }

    // MARK: Interactions

    /**
     Handle a tap. The old school way.
     */

    @objc func handleTap() {
        if showing == false {
            if detectedText != nil || detectedText.text! != "The image does not contain any text." {
                let components = detectedText.text!.components(separatedBy: " ")
                print("Components: \(components)")
                let filteredComponents = components.filter { $0 != "" }
                let parsedWords = filteredComponents.map {
                    TextCleaner(text: $0).returnLevens()
                }
                print(parsedWords)
                detectedText.text = parsedWords.joined(separator: " ")
                let presentBoard: UIStoryboard = UIStoryboard(name: "AudioViewController", bundle: nil)
                let vc = presentBoard.instantiateInitialViewController() as! AudioViewController
                vc.configure(widgetNames: parsedWords)
                addChildViewController(vc)
                view.addSubview(vc.view)
                showing = true
            }
        } else {
            print(view.subviews)
        }
    }

    /**
     Click on the camera button in the app to trigger this.
     */

    @IBAction func pickImageClicked(_: UIButton) {
        print("save the contents of ImageView to UIImage and process")
        clearOldData()
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    /**
     This is when the Gallery button is clicked.
     */

    @IBAction func galleryImageClicked(_: Any) {
        showImagePicker(withType: .photoLibrary)
    }

    /**
     Show the image picker. This would work with camera and gallery.

     The camera image picker has since gone onto greener pastures.
     */

    func showImagePicker(withType type: UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = type
        present(pickerController, animated: true)
    }

    /**
     This will fix the orientation of the image, send it to the Vision CoreML parser.
     */

    func imagePickerController(_: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String: Any]) {
        dismiss(animated: true)
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Couldn't load image")
        }
        let newImage = fixOrientation(image: image)
        imageView.image = newImage
        clearOldData()
        DispatchQueue.global(qos: .userInteractive).async {
            self.detectText(image: newImage)
        }
    }

    // MARK: text detection

    func detectText(image: UIImage) {
        let convertedImage = image |> adjustColors |> convertToGrayscale
        let handler = VNImageRequestHandler(cgImage: convertedImage.cgImage!)
        let request: VNDetectTextRectanglesRequest =
            VNDetectTextRectanglesRequest(completionHandler: { [unowned self] request, error in
                if error != nil {
                    print("Got Error In Run Text Dectect Request :(")
                } else {
                    guard let results = request.results as? [VNTextObservation] else {
                        fatalError("Unexpected result type from VNDetectTextRectanglesRequest")
                    }
                    if results.count == 0 {
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
        let request = VNCoreMLRequest(model: model) { [weak self] request, _ in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            let result = topResult.identifier
            print(result)
            let classificationInfo: [String: Any] = [
                "wordNumber": wordNumber,
                "characterNumber": characterNumber,
                "class": result,
            ]
            self?.handleResult(classificationInfo)
        }
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert UIImage to CIImage :(")
        }
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
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
        if textMetadata[wordNumber] == nil {
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
        if textMetadata.isEmpty {
            detectedText.text = "The image does not contain any text."
            return
        }
        let sortedKeys = textMetadata.keys.sorted()
        for sortedKey in sortedKeys {
            result += word(fromDictionary: textMetadata[sortedKey]!) + " "
        }
        detectedText.text = result
    }

    func word(fromDictionary dictionary: [Int: String]) -> String {
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
}

// MARK: Delegate extensions

extension LandingViewController: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {

    func captureOutput(_: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from _: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        var requestOptions: [VNImageOption: Any] = [:]

        if let camData = CMGetAttachment(sampleBuffer, kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, nil) {
            requestOptions = [.cameraIntrinsics: camData]
        }
    }
    
    // Thanks, Apple.
    // swiftlint:disable line_length
    public func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings _: AVCaptureResolvedPhotoSettings, bracketSettings _: AVCaptureBracketedStillImageSettings?, error: Error?) {
        print("yay?!?!?!")
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            print("ok, should be here?")

            let sampleBuffer = photoSampleBuffer

            if sampleBuffer != nil {
                let ImageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
                let dataProvider = CGDataProvider(data: ImageData! as CFData)
                let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
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
