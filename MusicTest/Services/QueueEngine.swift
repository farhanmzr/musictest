//
//  QueueEngine.swift
//  MusicTest
//
//  Created by Farhan Mazario on 03/08/22.
//

import Foundation
import UIKit

class QueueEngine {
    
    static var sharedInstance: QueueRules = QueueEngine()
    
    private var musicPlayer: SongRules = SongEngine.sharedInstance
    
    private var currentState: State = .Stop
    
    private var listAntrian: [Track] = []
    var getSong: ((Track) -> ())?
    
    var getProgresTime: ((Double) -> ())?
    var getUpdateDuration: ((Double) -> ())?
    var getUpdateBuffer: ((Double) -> ())?
    var playerError: ((Error) -> ())?
    var updateState: ((State) -> Void)?
    var getNowPlaying: ((Track) -> ())?
    
    init() {
        musicPlayer.updateState = { [weak self] state in
            
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.currentState == .Stop && state == .Playing {
                
            }
            
            strongSelf.currentState = state
            strongSelf.updateState?(state)
        }
        
        musicPlayer.getUpdateDuration = { [weak self] duration in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.getUpdateDuration?(duration)
            
        }
        
        musicPlayer.getProgresTime = { [weak self] timeElapsed in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.getProgresTime?(timeElapsed)
        }
        
    }
    
}


extension QueueEngine: QueueRules {
    
    func addQueue(track: [Track]) {
        listAntrian = track
        
        musicPlayer.setSong(item: listAntrian[0])
        getSong?(listAntrian[0])
        getNowPlaying?(listAntrian[0])
        musicPlayer.play()
    }
    
    func updateQueue() {
        
    }
    
    func checkState(state: PlayerState) {
        
    }
    
    
}
