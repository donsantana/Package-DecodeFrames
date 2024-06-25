//
//  File.swift
//  
//
//  Created by Done Santana on 6/20/24.
//

import Foundation


struct FileService {
    static var shared = FileService()
    let fileManager = FileManager.default
    
    func filePath(file: String) -> Data {
        guard let url = Bundle.main.url(forResource: file, withExtension: "nil") else {
            fatalError("Could no find \(file) in the project!")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not lead \(file) in the project!")
        }
        return data
    }
    
    func loadFileFromBundle(filename: String, withExtension ext: String) -> String? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: ext) else {
            print("File not found")
            return nil
        }

        do {
            let contents = try String(contentsOf: url, encoding: .utf8)
            return contents
        } catch {
            print("Error reading file: \(error)")
            return nil
        }
    }
    
    func getAllVideoFiles() -> [String] {
        let path = Bundle.main.resourcePath!
        do {
            let fileURLs = try fileManager.contentsOfDirectory(atPath: path)
            // process files
            print("Files \(fileURLs)")
            return fileURLs.filter({$0.hasSuffix("h265")})
        } catch {
            print("Error while enumerating files \(path): \(error.localizedDescription)")
        }
        return []
    }
}
