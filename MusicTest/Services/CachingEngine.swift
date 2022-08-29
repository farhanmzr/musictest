//
//  CachingEngine.swift
//  MusicTest
//
//  Created by Farhan Mazario on 18/08/22.
//

import Foundation
import Alamofire

//download dr sistem
class CachingEngine {
    
    static var sharedInstance: CachingRules = CachingEngine()
    
}

extension CachingEngine : CachingRules {
    
    func downloadFileSong(track: Track) {
        if let audioUrl = URL(string: track.url) {
        
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
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
        }
    }
    
    func removeFileSong(completion: (ResultProgress) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs where fileURL.pathExtension == "mp3" {
                try FileManager.default.removeItem(at: fileURL)
            }
            completion(.Success)
        } catch  {
            completion(.Failed)
            print(error)
        }
    }
    
    
}
