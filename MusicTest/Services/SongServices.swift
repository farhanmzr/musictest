//
//  SongServices.swift
//  MusicTest
//
//  Created by Farhan Mazario on 15/07/22.
//

import Foundation

class SongServices: SongFunc {
    
    static let shared: SongServices = SongServices()
    private init() {}
    
    
    
    
    
    func checkBookFileExists(withLink link: String, completion: @escaping ((URL) -> Void)) {
        let urlString = link.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            if let url  = URL.init(string: urlString ?? ""){
                let fileManager = FileManager.default
                if let documentDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: false){

                    let filePath = documentDirectory.appendingPathComponent(url.lastPathComponent, isDirectory: false)

                    do {
                        if try filePath.checkResourceIsReachable() {
                            print("file exist")
                            completion(filePath)

                        } else {
                            print("file doesnt exist")
                            downloadFile(withUrl: url, andFilePath: filePath, completion: completion)
                        }
                    } catch {
                        print("file doesnt exist")
                        downloadFile(withUrl: url, andFilePath: filePath, completion: completion)
                    }
                } else {
                     print("file doesnt exist")
                }
            } else {
                print("file doesnt exist")
        }
    }
    
    func downloadFile(withUrl url: URL, andFilePath filePath: URL, completion: @escaping ((URL) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: filePath, options: .atomic)
                print("Saved at \(filePath.absoluteString)")
                DispatchQueue.main.async {
                    completion(filePath)
                }
            } catch {
                print("An error happened while downloading or saving the file")
            }
        }
    }
    
    
}

protocol SongFunc {
    
    
    
    func checkBookFileExists(withLink link: String, completion: @escaping ((_ filePath: URL)->Void))
    
    func downloadFile(withUrl url: URL, andFilePath filePath: URL, completion: @escaping ((_ filePath: URL)->Void))
    
}
