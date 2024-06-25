//
//  SwiftUIView.swift
//  
//
//  Created by Done Santana on 6/20/24.
//

import SwiftUI

public struct VideoListView: View {
    @State var videoSelectedName = ""
    @State var showPreview = false
    @State var videoFilesURL: [String] = FileService.shared.getAllVideoFiles()
    
    public var body: some View {
        VStack {
            ForEach(videoFilesURL.indices, id: \.self) { index in
                Text("\(videoFilesURL[index])")
                    .onTapGesture {
                        videoSelectedName = videoFilesURL[index]
                        print(videoSelectedName)
                        showPreview = true
                    }
            }
            .onAppear() {
                videoFilesURL = FileService.shared.getAllVideoFiles()
            }
        }
        .fullScreenCover(isPresented: $showPreview, content: {
            VideoPreview(url: Bundle.main.url(forResource: "Big_Buck_Bunny.mov", withExtension: nil)!)
        })
    }
    public init() {}
}

#Preview {
    VideoListView()
}
