//
//  QueueRules.swift
//  MusicTest
//
//  Created by Farhan Mazario on 04/08/22.
//

import Foundation

protocol QueueRules {
    func addQueue(track:[Track])
    func updateQueue()
    func checkState(state:PlayerState)
    var getNowPlaying: ((Track) -> ())? { get set }
    var getProgresTime: ((Double) -> ())? { get set }
    var getUpdateDuration: ((Double) -> ())? { get set }
    var getUpdateBuffer: ((Double) -> ())? { get set }
    var playerError: ((Error) -> ())? { get set }
    var updateState: ((State) -> Void)? { get set }
}



