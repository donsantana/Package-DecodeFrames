//
//  File.swift
//  
//
//  Created by Done Santana on 6/21/24.
//

import AVFoundation
import VideoToolbox
import CoreVideo
import CoreImage
import SwiftUI

class VideoDecoder: ObservableObject {
    var decompressionSession: VTDecompressionSession?
    var formatDescription: CMVideoFormatDescription?
    var player: AVPlayer!
    @Published var playerItem: AVPlayerItem!
    var assetReader: AVAssetReader!
    
    @Published var frames: [UIImage] = []
    
    init(url: URL) {
        setupDecoder(url: url)
        player = AVPlayer()
        playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
    }
    
    deinit {
        teardownDecoder()
    }
    
    private func setupDecoder(url: URL) {
        let asset = AVAsset(url: url)
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            print("Error creating AVAssetReader: \(error)")
            return
        }
        
        guard let track = asset.tracks(withMediaType: .video).first else {
            print("No video tracks found")
            return
        }
        
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
        assetReader.add(readerOutput)
        
        if !assetReader.startReading() {
            print("Error starting AVAssetReader")
            return
        }
        
        guard let formatDescription = track.formatDescriptions.first else {
            print("Failed to get format description")
            return
        }
        
        self.formatDescription = formatDescription as! CMVideoFormatDescription
        
        var callback = VTDecompressionOutputCallbackRecord(
            decompressionOutputCallback: decompressionOutputCallback,
            decompressionOutputRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        let videoAttributes: [NSString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey: 1920,
            kCVPixelBufferHeightKey: 1080,
            kCVPixelBufferOpenGLCompatibilityKey: true
        ]

        let status = VTDecompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            formatDescription: formatDescription as! CMVideoFormatDescription,
            decoderSpecification: nil,
            imageBufferAttributes: videoAttributes as CFDictionary,
            outputCallback: &callback,
            decompressionSessionOut: &decompressionSession
        )

        if status != noErr {
            print("Error creating decompression session: \(status)")
            return
        }
        
        decodeVideo(readerOutput: readerOutput)
    }
    
    private func teardownDecoder() {
        if let session = decompressionSession {
            VTDecompressionSessionInvalidate(session)
        }
        decompressionSession = nil
        formatDescription = nil
    }
    
    private func decodeVideo(readerOutput: AVAssetReaderTrackOutput) {
        while assetReader.status == .reading {
            if let sampleBuffer = readerOutput.copyNextSampleBuffer() {
                decodeSampleBuffer(sampleBuffer)
            }
        }
        
        if assetReader.status == .completed {
            print("Finished reading and decoding")
        } else {
            print("Error reading video: \(assetReader.status.rawValue)")
        }
    }
    
    private func decodeSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
        guard let session = decompressionSession else { return }

        var flags: VTDecodeFrameFlags = []
        var flagOut: VTDecodeInfoFlags = []

        let status = VTDecompressionSessionDecodeFrame(
            session,
            sampleBuffer: sampleBuffer,
            flags: flags,
            frameRefcon: nil,
            infoFlagsOut: &flagOut
        )

        if status != noErr {
            print("Error decoding frame: \(status)")
        }
    }
    
    private let decompressionOutputCallback: VTDecompressionOutputCallback = { (outputCallbackRefCon, sourceFrameRefCon, status, infoFlags, imageBuffer, presentationTimeStamp, presentationDuration) in
        guard status == noErr else {
            if status == kVTVideoDecoderMalfunctionErr {
                print("Decompression error: Decoder malfunction (error code: -8971)")
            } else {
                print("Decompression error: \(status)")
            }
            return
        }

        guard let imageBuffer = imageBuffer else {
            print("No image buffer")
            return
        }

        let selfInstance = Unmanaged<VideoDecoder>.fromOpaque(outputCallbackRefCon!).takeUnretainedValue()
        
        // Convert imageBuffer to UIImage
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                selfInstance.frames.append(uiImage)
            }
        }
        print("Decompressed frame at presentation time: \(CMTimeGetSeconds(presentationTimeStamp))")
    }
}
