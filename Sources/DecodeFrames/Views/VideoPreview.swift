//
//  SwiftUIView.swift
//  
//
//  Created by Done Santana on 6/21/24.
//

import SwiftUI
import VideoToolbox
import AVKit

struct VideoPreview: View {
    @StateObject private var videoDecoder: VideoDecoder
    @State private var player: AVPlayer = AVPlayer()
    @State var url: URL
    
    init(url: URL) {
        self.url = url
        _videoDecoder = StateObject(wrappedValue: VideoDecoder(url: url))
        _player = State(initialValue: AVPlayer(url: url))
    }
    
    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: url))
                .frame(height: 400)
        }
    }
}

#Preview {
    VideoPreview(url: Bundle.main.url(forResource: "frames-7519.h265", withExtension: nil)!)
}

