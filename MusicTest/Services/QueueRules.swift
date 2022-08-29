//
//  QueueRules.swift
//  MusicTest
//
//  Created by Farhan Mazario on 04/08/22.
//

import Foundation

protocol QueueRules {
    func addQueue(track:[Track], index: Int)
    func moveAutoNextQueue()
    func moveNextQueue()
    func movePrevQueue()
    func updateQueue()
    func checkState(state: State)
    var getNowPlaying: ((Track) -> ())? { get set }
    var getProgresTime: ((Double) -> ())? { get set }
    var getUpdateDuration: ((Double) -> ())? { get set }
    var getUpdateBuffer: ((Double) -> ())? { get set }
    var playerError: ((Error) -> ())? { get set }
    var updateState: ((State) -> Void)? { get set }
    
    func downloadFileSong(track: Track)
    func downloadCustomFileSong(track: Track)
    func removeSong()
    
    var removeCustomFilesSong: ((ResultProgress) -> ())? { get set }
    var removeFilesSong: ((ResultProgress) -> ())? { get set }

}

enum ResultProgress {
    case Success
    case Failed
}


