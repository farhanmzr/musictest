//
//  FilesRules.swift
//  MusicTest
//
//  Created by Farhan Mazario on 18/08/22.
//

import Foundation

protocol FilesRules {
    
    func removeCustomFileSong(completion: (_ result: ResultProgress) -> Void)
    
    func downloadCustomFolderSong(track: Track)
    
    
    
}
