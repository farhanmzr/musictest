//
//  CachingRules.swift
//  MusicTest
//
//  Created by Farhan Mazario on 18/08/22.
//

import Foundation

protocol CachingRules {
    
    func downloadFileSong(track: Track)
    
    func removeFileSong(completion: (_ result: ResultProgress) -> Void)
    
}
