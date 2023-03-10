//
//  ImageUtils.swift
//  PaperSynth
//
//  Created by Ashvala Vinay on 12/8/17.
//  Copyright © 2017 Ashvala Vinay. All rights reserved.
//
// Borrowed from Martin Mitrevski's article on CoreML and vision.

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import Vision

precedencegroup ForwardPipe {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

infix operator |>: ForwardPipe

/// Swift implementation of the forward pipe operator from F#.
///
/// Used for better readibility when piping results of one function to the next ones.
/// More details here: https://goo.gl/nHzeS6.
public func |> <T, U>(value: T, function: ((T) -> U)) -> U {
    return function(value)
}

func resize(image: UIImage, targetSize: CGSize) -> UIImage {
    let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
}

func convertToGrayscale(image: UIImage) -> UIImage {
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
    let context = CGContext(data: nil,
                            width: Int(UInt(image.size.width)),
                            height: Int(UInt(image.size.height)),
                            bitsPerComponent: 8,
                            bytesPerRow: 0,
                            space: colorSpace,
                            bitmapInfo: bitmapInfo.rawValue)
    context?.draw(image.cgImage!,
                  in: CGRect(x: 0.0, y: 0.0, width: image.size.width, height: image.size.height))
    let imageRef: CGImage = context!.makeImage()!
    let newImage: UIImage = UIImage(cgImage: imageRef)
    return newImage
}

func insertInsets(image: UIImage, insetWidthDimension: CGFloat, insetHeightDimension: CGFloat)
    -> UIImage {
    let adjustedImage = adjustColors(image: image)
    let upperLeftPoint: CGPoint = CGPoint(x: 0, y: 0)
    let lowerLeftPoint: CGPoint = CGPoint(x: 0, y: adjustedImage.size.height - 1)
    let upperRightPoint: CGPoint = CGPoint(x: adjustedImage.size.width - 1, y: 0)
    let lowerRightPoint: CGPoint = CGPoint(x: adjustedImage.size.width - 1,
                                           y: adjustedImage.size.height - 1)
    let upperLeftColor: UIColor = getPixelColor(fromImage: adjustedImage, pixel: upperLeftPoint)
    let lowerLeftColor: UIColor = getPixelColor(fromImage: adjustedImage, pixel: lowerLeftPoint)
    let upperRightColor: UIColor = getPixelColor(fromImage: adjustedImage, pixel: upperRightPoint)
    let lowerRightColor: UIColor = getPixelColor(fromImage: adjustedImage, pixel: lowerRightPoint)
    let color =
        averageColor(fromColors: [upperLeftColor, lowerLeftColor, upperRightColor, lowerRightColor])
    let insets = UIEdgeInsets(top: insetHeightDimension,
                              left: insetWidthDimension,
                              bottom: insetHeightDimension,
                              right: insetWidthDimension)
    let size = CGSize(width: adjustedImage.size.width + insets.left + insets.right,
                      height: adjustedImage.size.height + insets.top + insets.bottom)
    UIGraphicsBeginImageContextWithOptions(size, false, adjustedImage.scale)
    let origin = CGPoint(x: insets.left, y: insets.top)
    adjustedImage.draw(at: origin)
    let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return convertTransparent(image: imageWithInsets!, color: color)
}

func averageColor(fromColors colors: [UIColor]) -> UIColor {
    var averages = [CGFloat]()
    for i in 0 ..< 4 {
        var total: CGFloat = 0
        for j in 0 ..< colors.count {
            let current = colors[j]
            let value = CGFloat(current.cgColor.components![i])
            total += value
        }
        let avg = total / CGFloat(colors.count)
        averages.append(avg)
    }
    return UIColor(red: averages[0], green: averages[1], blue: averages[2], alpha: averages[3])
}

func adjustColors(image: UIImage) -> UIImage {
    let context = CIContext(options: nil)
    if let currentFilter = CIFilter(name: "CIColorControls") {
        let beginImage = CIImage(image: image)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        currentFilter.setValue(0, forKey: kCIInputSaturationKey)
        currentFilter.setValue(1.45, forKey: kCIInputContrastKey) // previous 1.5
        if let output = currentFilter.outputImage {
            if let cgimg = context.createCGImage(output, from: output.extent) {
                let processedImage = UIImage(cgImage: cgimg)
                return processedImage
            }
        }
    }
    return image
}

func fixOrientation(image: UIImage) -> UIImage {
    if image.imageOrientation == UIImageOrientation.up {
        return image
    }
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
    if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
        UIGraphicsEndImageContext()
        return normalizedImage
    } else {
        return image
    }
}

func convertTransparent(image: UIImage, color: UIColor) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let width = image.size.width
    let height = image.size.height
    let imageRect: CGRect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
    let ctx: CGContext = UIGraphicsGetCurrentContext()!
    let redValue = CGFloat(color.cgColor.components![0])
    let greenValue = CGFloat(color.cgColor.components![1])
    let blueValue = CGFloat(color.cgColor.components![2])
    let alphaValue = CGFloat(color.cgColor.components![3])
    ctx.setFillColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    ctx.fill(imageRect)
    image.draw(in: imageRect)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}

func getPixelColor(fromImage image: UIImage, pixel: CGPoint) -> UIColor {
    let pixelData = image.cgImage!.dataProvider!.data
    let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
    let pixelInfo: Int = ((Int(image.size.width) * Int(pixel.y)) + Int(pixel.x)) * 4
    let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
    let g = CGFloat(data[pixelInfo + 1]) / CGFloat(255.0)
    let b = CGFloat(data[pixelInfo + 2]) / CGFloat(255.0)
    let a = CGFloat(data[pixelInfo + 3]) / CGFloat(255.0)
    return UIColor(red: r, green: g, blue: b, alpha: a)
}

func crop(image: UIImage, rectangle: VNRectangleObservation) -> UIImage? {
    var t: CGAffineTransform = CGAffineTransform.identity
    t = t.scaledBy(x: image.size.width, y: -image.size.height)
    t = t.translatedBy(x: 0, y: -1)
    let x = rectangle.boundingBox.applying(t).origin.x
    let y = rectangle.boundingBox.applying(t).origin.y
    let width = rectangle.boundingBox.applying(t).width
    let height = rectangle.boundingBox.applying(t).height
    let fromRect = CGRect(x: x, y: y, width: width, height: height)
    let drawImage = image.cgImage!.cropping(to: fromRect)
    if let drawImage = drawImage {
        let uiImage = UIImage(cgImage: drawImage)
        return uiImage
    }
    return nil
}

func preProcess(image: UIImage) -> UIImage {
    let width = image.size.width
    let height = image.size.height
    let addToHeight2 = height / 2
    let addToWidth2 = ((6 * height) / 3 - width) / 2
    let imageWithInsets = insertInsets(image: image,
                                       insetWidthDimension: addToWidth2,
                                       insetHeightDimension: addToHeight2)
    let size = CGSize(width: 64, height: 64)
    let resizedImage = resize(image: imageWithInsets, targetSize: size)
    let grayScaleImage = convertToGrayscale(image: resizedImage)
    return grayScaleImage
}

func extractContoursFromImage(image:UIImage) -> UIImage{
    // use VNDetectContoursRequest
    // convert image to monochrome
    let context = CIContext()
    let sourceImage = image.cgImage!
    let inputImage = CIImage.init(cgImage: sourceImage)
    // make input image monochrome
    let preProcessed = preProcessImage(image: image)
    let finalInput = preProcessed.cgImage!
    let requestHandler = VNImageRequestHandler(cgImage: finalInput, options: [:])
    let request: VNDetectContoursRequest = {
        let req = VNDetectContoursRequest()
        req.contrastAdjustment = 1.0
        req.detectsDarkOnLight = true
        req.maximumImageDimension = 512
        req.contrastPivot = nil
      return req
    }()
    do {
        try requestHandler.perform([request])
        // get contours
        let contours = request.results!
        print(contours[0].contourCount)
        // filter contours

        return drawContours(contoursObservation: contours[0], sourceImage: image.cgImage!)
        
    } catch {
        print(error)
    }
    return image
}

func preProcessImage(image: UIImage) -> UIImage{
    let context = CIContext()
    let sourceImage = image.cgImage!
    let inputImage = CIImage.init(cgImage: sourceImage)
    // make input image monochrome
    let blackAndWhite = CustomFilter()
    let noiseReductionFilter = CIFilter.gaussianBlur()
    noiseReductionFilter.radius = 0.5
    noiseReductionFilter.inputImage = inputImage
    blackAndWhite.inputImage = noiseReductionFilter.outputImage!
    let filteredImage = blackAndWhite.outputImage!
    let noiseReduced = noiseReduction(inputImage: filteredImage)
//    let gauss = gaussianBlur(inputImage: noiseReduced!)
    let finalInput = context.createCGImage(noiseReduced!, from: noiseReduced!.extent)!
    return UIImage(cgImage: finalInput)
}

func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage) -> UIImage {
    let size = CGSize(width: sourceImage.width, height: sourceImage.height)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let renderedImage = renderer.image { (context) in
    let renderingContext = context.cgContext

    let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
    renderingContext.concatenate(flipVertical)

    renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
    
    renderingContext.scaleBy(x: size.width, y: size.height)
    renderingContext.setLineWidth(5.0 / CGFloat(size.width))
    let redUIColor = UIColor.red
    renderingContext.setStrokeColor(redUIColor.cgColor)
    renderingContext.addPath(contoursObservation.normalizedPath)
    renderingContext.strokePath()
    }
    
    return renderedImage
}

func gaussianBlur(inputImage: CIImage) -> CIImage? {
    let gaussianBlurFilter = CIFilter.gaussianBlur()
    gaussianBlurFilter.inputImage = inputImage
    gaussianBlurFilter.radius = 10
    return gaussianBlurFilter.outputImage
}

func noiseReduction(inputImage: CIImage) -> CIImage? {
    let noiseReductionfilter = CIFilter.noiseReduction()
    noiseReductionfilter.inputImage = inputImage
    noiseReductionfilter.noiseLevel = 0.2
    noiseReductionfilter.sharpness = 0.4
    return noiseReductionfilter.outputImage
}


class CustomFilter: CIFilter {
    var inputImage: CIImage?
    
    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage as AnyObject]
                
                let callback: CIKernelROICallback = {
                (index, rect) in
                    return rect.insetBy(dx: -1, dy: -1)
                }
                
                return createCustomKernel().apply(extent: inputImage.extent, roiCallback: callback, arguments: args)
            } else {
                return nil
            }
        }
    }

    
    func createCustomKernel() -> CIKernel {
            return CIColorKernel(source:
                "kernel vec4 replaceWithBlackOrWhite(__sample s) {" +
                    "if (s.r > 0.25 && s.g > 0.25 && s.b > 0.25) {" +
                    "    return vec4(0.0,0.0,0.0,1.0);" +
                    "} else {" +
                    "    return vec4(1.0,1.0,1.0,1.0);" +
                    "}" +
                "}"
                )!
           
        }
}

