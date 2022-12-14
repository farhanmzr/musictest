//
//  SongRule.swift
//  MusicTest
//
//  Created by Farhan Mazario on 19/07/22.
//

import Foundation
import AVFoundation

enum SongError: Error, LocalizedError {
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

protocol SongRules {
    
    func play()
    func stop()
    func pause()
    func seek(duration: Double, slider: Float)
    func togglePlayPause()
    func getDuration() -> Double?
    func getTimeElapsed() -> Double?
    func setSong<T>(item: T)
    
    var playerError: ((Error) -> ())? { get set }
    var updateState: ((State) -> Void)? { get set }
//    var getSong: ((Track) -> Void)? {get set}
    var getProgresTime: ((Double) -> ())? { get set }
    var getUpdateDuration: ((Double) -> ())? { get set }
    var getUpdateBuffer: ((Double) -> ())? { get set }

}

enum State {
    case Playing
    case Pause
    case Seek
    case Stop
    case Loading
    case Ready
}

enum DoOnObservers {
    case RemoveObserver
    case AddObserver
}

protocol MediaPlayerSetupRules: AnyObject {
    var player: AVPlayer { get }
}

protocol PrivateMediaPlayerRules: AnyObject {
    func doPlay()
    func doPause()
    func doReplaceCurrentItem()
    func errorInfo(message error: Error)
}

protocol MediaPlayerPresenterRules {
    func checkState_Seek(state: State)
    func toggle(state: State)
    func checkCurrentItem(item: AVPlayerItem?)
}

protocol DownloadFileSong {
    func downloadFileSong(track: Track)
    func downloadCustomFolderSong(urlSong: String)
}

protocol RemoveFileSong {
    func removeFileSong(completion: (_ result: Bool) -> Void)
}

protocol MediaPlayerInfoCenter {
    func setupNowPlaying(state: Bool, dict: [String:Any?], track: Track)
}

protocol MediaPlayerCommandCenterRule {
    func setupRemoteCommandCenter()
}

protocol SongPlayerObserverRule {
    func registerObserver(item: AVPlayerItem?)
}

protocol PrivateSongPlayerObserverRule {
    func removeNotification(item:AVPlayerItem)
    func addNotification(item:AVPlayerItem)
    func getLastPlayedItem() -> AVPlayerItem?
    func getTimeObserver() -> Any?
    func setTimeObserver(timeObserver: Any?)
    func setTimeObserver(interval: CMTime)
    func doUpdateDuration(duration: Double)
    func playbackLikelyToKeepUp_loading()
    func playbackLikelyToKeepUp_ready()
    func getPlayerStatus() -> AVPlayer.Status
    func setBufferObserver()
    
}

protocol SongPlayerObserverPresenterRule {
    func checkPlayerItem(item:AVPlayerItem?,task: DoOnObservers)
    func checkKey(object:Any?,key:String?,playerItem:AVPlayerItem?)
}



