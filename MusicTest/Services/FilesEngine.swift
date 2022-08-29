//
//  FilesEngine.swift
//  MusicTest
//
//  Created by Farhan Mazario on 18/08/22.
//

import Foundation
import Alamofire

class FilesEngine {
    
    static var sharedInstance: FilesRules = FilesEngine()
    
}

extension FilesEngine: FilesRules {
    
    func removeCustomFileSong(completion: (ResultProgress) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioKitFilesFolder = documentsUrl.appendingPathComponent("CustomSongFilesFolder")
        do {
            let customFileURLs = try FileManager.default.contentsOfDirectory(at: audioKitFilesFolder, includingPropertiesForKeys: nil, options: [])
            for customFileURL in customFileURLs where customFileURL.pathExtension == "mp3" {
                try FileManager.default.removeItem(at: customFileURL)
            }
            completion(.Success)
        } catch  {
            completion(.Failed)
            print(error)
        }
    }
    
    func downloadCustomFolderSong(track: Track) {
        if let audioUrl = URL(string: track.url) {
        
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let audioKitFilesFolder = documentsDirectoryURL.appendingPathComponent("CustomSongFilesFolder")
            // lets create your destination file url
            do {
                try FileManager.default.createDirectory(atPath: audioKitFilesFolder.path, withIntermediateDirectories: true, attributes: nil)
                
                let destinationUrl = audioKitFilesFolder.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("The file already exists at path when download")
                // if the file doesn't exist
                } else {
                    let destination: DownloadRequest.Destination = { _, _ in
                        return (destinationUrl, [.removePreviousFile])
                    }
                    AF.download(audioUrl, to: destination)
                    .downloadProgress { progress in
                        print("Download Progress: \(progress.fractionCompleted)")
                    }
                    .response { response in
                        if response.error == nil {
                            print("Success Download")
                            
                        } else {
                            print(response.error?.errorDescription)
                        }
                    }
                }
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
}
