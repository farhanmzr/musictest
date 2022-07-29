//
//  MediaPlayerRule.swift
//  eConcertLangitMusik
//
//  Created by Jan Sebastian on 09/06/22.
//

import Foundation
import AVFoundation

enum PlayerError: Error, LocalizedError {
    case AVPlayerItemEmpty
    
    var errorDescription: String? {
        switch self {
        case .AVPlayerItemEmpty:
            return NSLocalizedString(
                "Failed add notification, AVPlayerItem empty",
                comment: ""
            )
        }
    }
}


enum PlayerState {
    case Playing
    case Pause
    case Seek
    case Stop
    case Loading
    case Ready
}

enum DoOnObserver {
    case RemoveObserver
    case AddObserver
}

protocol PlayerDelegate: AnyObject {
    func updateProgresTime(time: Double)
    func updateDuration(time: Double)
    func updateState(state: PlayerState)
    func updateBuffer(second: Double)
}

protocol MediaPlayerRule {
    var playerDelegate: PlayerDelegate? { get set }
    func play()
    func stop()
    func pause()
    func setSong(url: String)
    func seek(timeTo: Double)
    func togglePlayPause()
    func getDuration() -> Double?
    func getTimeElapsed() -> Double?
    var updateDuration: (() -> Void)? { get set }
    var updateTimeElapsed: (() -> Void)? { get set }
    var playerError: ((Error) -> ())? { get set }
    var updateState: ((PlayerState) -> Void)? { get set }
    func videoView() -> AVPlayerLayer
}

protocol MediaPlayerObservable {
    
}


