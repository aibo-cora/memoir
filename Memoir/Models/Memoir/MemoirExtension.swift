//
//  MemoirExtension.swift
//  Memoir
//
//  Created by Yura on 7/10/19.
//  Copyright © 2019 Symbiosis. All rights reserved.
//

import Foundation
import AssetsPickerViewController
import Photos
import AVFoundation

extension ViewController: AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        //TODO
        // Select photos from the photo library, add to an array
        let outputSize = CGSize(width: 1920,
                                height: 1280)
        //Creating temp path to save the video file created from images
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                          in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("memoir.mp4")
        
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                fatalError("Unable to detele file. Program ended prematurely.")
            }
        }
        
        print("Number of photos selected: \(assets.count)")
        let chosenPhotos: [UIImage] = convertAssets(assets: assets)
//        testConvertedImages(images: chosenPhotos)
        
        guard let videoWriter = try? AVAssetWriter(outputURL: filePath, fileType: AVFileType.mp4) else {
            fatalError("AssetWriter Error")
        }
        
        let outputSettings = [AVVideoCodecKey : AVVideoCodecType.h264,
                              AVVideoWidthKey : NSNumber(value: Float(outputSize.width)),
                              AVVideoHeightKey: NSNumber(value: Float(outputSize.height))]  as [String : Any]
        guard videoWriter.canApply(outputSettings: outputSettings,
                                   forMediaType: .video) else {
                                    fatalError("Failed to apply output settings.")
        }
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: outputSettings)
        let sourcePixelBufferAttributesDictionary =
            [kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: NSNumber(value: Float(outputSize.width)),
            kCVPixelBufferHeightKey as String: NSNumber(value: Float(outputSize.height))]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary)
        if videoWriter.canAdd(videoWriterInput) {
            videoWriter.add(videoWriterInput)
        }
        
//        if videoWriter.startWriting() {
//            videoWriter.startSession(atSourceTime: CMTime.zero)
//            assert(pixelBufferAdaptor.pixelBufferPool != nil)
//            let media_queue = DispatchQueue(label: "mediaInputQueue")
//            videoWriterInput.requestMediaDataWhenReady(on: media_queue, using: { () -> Void in
//                let fps: Int32 = 1
//                let framePerSecond: Int64 = 5
//                let frameDuration = CMTimeMake(value: framePerSecond, timescale: fps)
//                var frameCount: Int64 = 0
//                var appendSucceeded = true
//                while (!self.choosenPhotos.isEmpty) { //choosenPhotos is image array
//                    if (videoWriterInput.isReadyForMoreMediaData) {
//                        let nextPhoto = self.choosenPhotos.remove(at: 0)
//                        let lastFrameTime = CMTimeMake(frameCount * framePerSecond, fps)
//                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
//                        print("presentationTime-------------\(presentationTime)")
//                        var pixelBuffer: CVPixelBuffer? = nil
//                        let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferAdaptor.pixelBufferPool!, &pixelBuffer)
//                        if let pixelBuffer = pixelBuffer, status == 0 {
//                            let managedPixelBuffer = pixelBuffer
//                            CVPixelBufferLockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//                            let data = CVPixelBufferGetBaseAddress(managedPixelBuffer)
//                            let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//                            let context = CGContext(data: data, width: Int(self.outputSize.width), height: Int(self.outputSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(managedPixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
//                            context!.clear(CGRect(x: 0, y: 0, width: CGFloat(self.outputSize.width), height: CGFloat(self.outputSize.height)))
//                            let horizontalRatio = CGFloat(self.outputSize.width) / nextPhoto.size.width
//                            let verticalRatio = CGFloat(self.outputSize.height) / nextPhoto.size.height
//                            //aspectRatio = max(horizontalRatio, verticalRatio) // ScaleAspectFill
//                            let aspectRatio = min(horizontalRatio, verticalRatio) // ScaleAspectFit
//                            let newSize: CGSize = CGSize(width: nextPhoto.size.width * aspectRatio, height: nextPhoto.size.height * aspectRatio)
//                            let x = newSize.width < self.outputSize.width ? (self.outputSize.width - newSize.width) / 2 : 0
//                            let y = newSize.height < self.outputSize.height ? (self.outputSize.height - newSize.height) / 2 : 0
//                            context?.draw(nextPhoto.cgImage!, in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
//                            CVPixelBufferUnlockBaseAddress(managedPixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//                            appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
//                        } else {
//                            print("Failed to allocate pixel buffer")
//                            appendSucceeded = false
//                        }
//                    }
//                    if !appendSucceeded {
//                        break
//                    }
//                    frameCount += 1
//                }
//                videoWriterInput.markAsFinished()
//                videoWriter.finishWriting { () -> Void in
//                    self.imageArrayToVideoComplete = true
//                    print("Image array to mutable video complete :)")
//                }
//            })
//        }
    }
    
    //MARK: Convert array of PHAssets to UIImage
    func convertAssets(assets: [PHAsset]) -> [UIImage] {
        var images = [UIImage]()
        let outputSize = CGSize(width: 1920,
                                height: 1280)
        
        for asset in assets {
            let manager = PHImageManager.default()
            let options = PHImageRequestOptions()
            
            options.isSynchronous = true
            manager.requestImage(for: asset,
                                 targetSize: outputSize,
                                 contentMode: .aspectFit,
                                 options: options) { (image, info) in
                                    images.append(image!)
            }
        }
        
        return images
    }
    
    func testConvertedImages(images: [UIImage]) {
        var count = 0
        for image in images {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory,
                                                              in: .userDomainMask)[0] as URL
            let filePath = documentsDirectory.appendingPathComponent("image\(count).png")
            print(filePath)
            count = count + 1
            // save image
            do {
                try image.pngData()?.write(to: filePath, options: .atomic)
            }
            catch {
                fatalError("Error writing image")
            }
        }
    }
}
