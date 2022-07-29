//
//  SongEngineObserverPresenter.swift
//  MusicTest
//
//  Created by Farhan Mazario on 25/07/22.
//

import Foundation
import AVFoundation

class SongEngineObserverPresenter {
    
    private let controller: PrivateSongPlayerObserverRule?
    
    init(controller: PrivateSongPlayerObserverRule) {
        self.controller = controller
    }
}

extension SongEngineObserverPresenter : SongPlayerObserverPresenterRule {
    
    func checkKey(object: Any?, key: String?, playerItem: AVPlayerItem?) {
        if let item = object as? AVPlayerItem, let keyPath = key, item == playerItem {
            
            switch keyPath {
            case "status":
                if controller?.getPlayerStatus() == AVPlayer.Status.readyToPlay {
                    controller?.playbackLikelyToKeepUp_ready()
                } else if controller?.getPlayerStatus() == AVPlayer.Status.failed {
                    print("status: Failed")
                }
            case "playbackBufferEmpty":
                break
            case "playbackLikelyToKeepUp":
                if item.isPlaybackLikelyToKeepUp == true {
                    controller?.playbackLikelyToKeepUp_ready()
                } else {
                    controller?.playbackLikelyToKeepUp_loading()
                }
            case "duration":
//                if CMTIME_IS_INDEFINITE(item.duration) || item.duration != .zero {
//                    if let timeObserver = controller?.getTimeObserver() {
//
//                        controller?.setTimeObserver(timeObserver: nil)
//
//                    }
//                }
//                else {
//                    let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//                    let duration = Double(CMTimeGetSeconds(item.duration))
//                    controller?.doUpdateDuration(duration: duration)
//                    controller?.setTimeObserver(interval: interval)
//                }
                let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                let duration = Double(item.duration.seconds)
                controller?.doUpdateDuration(duration: duration)
                controller?.setTimeObserver(interval: interval)
                
                let interval1 = CMTimeMake(value: 1, timescale: 1)
                controller?.setBufferObserver()
                
            case "loadedTimeRanges":
                 let interval1 = CMTimeMake(value: 1, timescale: 1)
                controller?.setBufferObserver()
                
            default:
                break
            }
            
        }
    }
    
    func checkPlayerItem(item: AVPlayerItem?, task: DoOnObservers) {
        if task == .AddObserver {
            
            guard let getPlayerItem = item else {
                
                print("Failed add notification, AVPlayerItem empty")
                
                return
            }
            
            controller?.addNotification(item: getPlayerItem)
        }
        else if task == .RemoveObserver {
            guard let getPlayerItem = item else {
                
                print("Failed remove notification, AVPlayerItem empty")
                
                return
            }
            
            controller?.removeNotification(item: getPlayerItem)
            
        }
    }
    
    
}

