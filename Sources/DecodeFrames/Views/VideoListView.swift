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
        Text("Select the video to decode and preview")
            .font(.headline)
        Divider()
        VStack {
            ForEach(videoFilesURL.indices, id: \.self) { index in
                Text("\(videoFilesURL[index])")
                    .onTapGesture {
                        videoSelectedName = videoFilesURL[index]
                        print(videoSelectedName)
                        showPreview = true
                    }
                    .padding(.all, 10)
            }
            .onAppear() {
                videoFilesURL = FileService.shared.getAllVideoFiles()
            }
        }
        .fullScreenCover(isPresented: $showPreview, content: {
            VideoPreview(url: Bundle.main.url(forResource: "frames-7501.h265", withExtension: nil)!)
        })
        Spacer()
    }
    public init() {}
}

#Preview {
    VideoListView()
}
