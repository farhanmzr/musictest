//
//  PlayerEngine.swift
//  eConcertLangitMusik
//
//  Created by Jan Sebastian on 09/06/22.
//

import Foundation
import AVFoundation
import MediaPlayer

fileprivate protocol MediaPlayerSetupRule: AnyObject {
    var player: AVPlayer { get }
}

fileprivate protocol PrivateMediaPlayerRule: AnyObject {
    func doPlay()
    func doPause()
    func doReplaceCurrentItem()
    func errorInfo(message error: Error)
}

fileprivate protocol MediaPlayerPresenterRule {
    func checkState_Seek(state: PlayerState)
    func toggle(state: PlayerState)
    func checkCurrentItem(item: AVPlayerItem?)
}

fileprivate protocol MediaPlayerObserverRule {
    func registerObserver(item: AVPlayerItem?)
}

protocol PrivateMediaPlayerObserverRule: AnyObject {
    func removeNotification(item: AVPlayerItem)
    func addNotification(item: AVPlayerItem)
    func getLastPlayedItem() -> AVPlayerItem?
    func getTimeObserver() -> Any?
    func setTimeObserver(timeObserver: Any?)
    func setTimeObserver(interval: CMTime)
    func doUpdateDuration(duration: Double)
    func playbackLikelyToKeepUpLoading()
    func playbackLikelyToKeepUpReady()
    func getPlayerStatus() -> AVPlayer.Status
    func setBufferObserver()
    func errorObserver(message error: Error)
}

fileprivate protocol MediaPlayerObserver {
    func checkPlayerItem(item: AVPlayerItem?, task: DoOnObserver)
    func checkKey(object: Any?, key: String?, playerItem: AVPlayerItem?)
}

class PlayerEngine: NSObject, MediaPlayerSetupRule {
    fileprivate var player: AVPlayer = {
        let setPlayer = AVPlayer()
        return setPlayer
    }()
    fileprivate var playerItem: AVPlayerItem? = nil
    private var isPlaying: PlayerState = .Stop {
        didSet {
            playerDelegate?.updateState(state: isPlaying)
            updateState?(isPlaying)
        }
    }
    private var presenter: MediaPlayerPresenterRule?
    private var playerObserver: MediaPlayerObserverRule?
    private var timeObserver: Any?
    private var bufferObserver: Any?
    private var lastPlayedItem: AVPlayerItem? = nil
    private var presenterObserver: MediaPlayerObserver?
    weak var playerDelegate: PlayerDelegate?
    static var sharedInstance: MediaPlayerRule = PlayerEngine()
    
    var updateDuration: (() -> ())?
    var updateTimeElapsed: (() -> ())?
    var updateState: ((PlayerState) -> ())?
    var playerError: ((Error) -> ())?
    
    override init() {
        super.init()
        presenter = MediaPlayerPresenter(controller: self)
        presenterObserver = MediaPlayerObserverPresenter(controller: self)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        presenterObserver?.checkKey(object: object, key: keyPath, playerItem: playerItem)
    }
    
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("keyPath: \(keyPath ?? "")")
    }
}

extension PlayerEngine: MediaPlayerRule {
    func getDuration() -> Double? {
        let duration = player.currentItem?.duration.seconds
        
        return duration
    }
    
    func getTimeElapsed() -> Double? {
        let timeElapsed = player.currentItem?.currentTime().seconds
        return timeElapsed
    }
    
    func play() {
        self.presenter?.checkCurrentItem(item: player.currentItem)
        player.play()
        isPlaying = .Playing
    }
    
    func stop() {
        isPlaying = .Stop
        player.pause()
        player.seek(to: .zero)
    }
    
    func pause() {
        isPlaying = .Pause
        player.pause()
    }
    
    func setSong(url: String) {
        let setupUrl = AVURLAsset(url: URL(string: url)!, options: [:])
        let songUrl = AVPlayerItem(asset: setupUrl)
        playerItem = songUrl
        playerItem?.preferredForwardBufferDuration = 5
        player = AVPlayer(playerItem: songUrl)
        isPlaying = .Loading
        registerObserver(item: songUrl)
    }
    
    @objc func itemDidPlayToEnd() {
        stop()
    }
    
    func seek(timeTo: Double) {
        
        let seekTime = CMTime(seconds: timeTo, preferredTimescale: 1)
        
        isPlaying = .Seek
        player.pause()
        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .positiveInfinity, completionHandler: { [weak self] result in
            self?.presenter?.checkState_Seek(state: (self?.isPlaying)!)
        })
    }
    
    func togglePlayPause() {
        self.presenter?.toggle(state: isPlaying)
    }
    
    func videoView() -> AVPlayerLayer {
        return AVPlayerLayer(player: player)
    }
    
}

extension PlayerEngine: PrivateMediaPlayerRule {
    fileprivate func doPlay() {
        self.play()
    }
    
    fileprivate func doPause() {
        self.pause()
    }
    
    fileprivate func doReplaceCurrentItem() {
        player.replaceCurrentItem(with: playerItem)
    }
    
    fileprivate func errorInfo(message error: Error) {
        playerError?(error)
    }
}

extension PlayerEngine: MediaPlayerObserverRule {
    func registerObserver(item: AVPlayerItem?) {
        presenterObserver?.checkPlayerItem(item: lastPlayedItem, task: .RemoveObserver)
        lastPlayedItem = item
        presenterObserver?.checkPlayerItem(item: item, task: .AddObserver)
    }
}

extension PlayerEngine: PrivateMediaPlayerObserverRule {
    func getPlayerStatus() -> AVPlayer.Status {
        return player.status
    }
    
    func playbackLikelyToKeepUpLoading() {
        isPlaying = .Loading
    }
    
    func playbackLikelyToKeepUpReady() {
        isPlaying = .Playing
    }
    
    func removeNotification(item: AVPlayerItem) {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
        item.removeObserver(self, forKeyPath: "status")
        item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        item.removeObserver(self, forKeyPath: "duration")
        item.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    
    func addNotification(item: AVPlayerItem) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidPlayToEnd), name: .AVPlayerItemDidPlayToEndTime, object: item)
        item.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "duration", options: .new, context: nil)
        item.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new], context: nil)
    }
    
    func getLastPlayedItem() -> AVPlayerItem? {
        return lastPlayedItem
    }
    
    func getTimeObserver() -> Any? {
        return timeObserver
    }
    
    func setTimeObserver(timeObserver: Any?) {
        self.timeObserver = timeObserver
    }
    
    func setTimeObserver(interval: CMTime) {
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { time in
            //do time update
            self.playerDelegate?.updateProgresTime(time: time.seconds)
            self.updateTimeElapsed?()
        })
    }
    
    func setBufferObserver() {
        
        if let bufferValue = player.currentItem?.loadedTimeRanges.last?.timeRangeValue.end.seconds {
            playerDelegate?.updateBuffer(second: bufferValue)
        }
        else {
            print("buffer still empty")
            playerDelegate?.updateBuffer(second: 0)
        }
    }
    
    func doUpdateDuration(duration: Double) {
        // totalTime
        playerDelegate?.updateDuration(time: duration)
        updateDuration?()
    }
    
    func errorObserver(message error: Error) {
        playerError?(error)
    }
}


fileprivate final class MediaPlayerPresenter: MediaPlayerPresenterRule {
    private unowned let controller: PrivateMediaPlayerRule?
    
    init(controller: PrivateMediaPlayerRule) {
        self.controller = controller
        
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            if #available(iOS 11.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, policy: .default, options: .mixWithOthers)
            } else {
                // Fallback on earlier versions
                try  AVAudioSession.sharedInstance().setCategory(.playback)
            }
        } catch let error {
            print("AVAudioSession error: \(error)")
            controller.errorInfo(message: error)
        }
    }
    
    func checkState_Seek(state: PlayerState) {
        if state != .Pause {
            self.controller?.doPlay()
        }
    }
    
    func toggle(state: PlayerState) {
        if state != .Stop {
            if state == .Pause {
                self.controller?.doPlay()
            } else {
                self.controller?.doPause()
            }
        }
    }
    
    func checkCurrentItem(item: AVPlayerItem?) {
        if item == nil {
            self.controller?.doReplaceCurrentItem()
        }
    }
}

fileprivate final class MediaPlayerObserverPresenter:  MediaPlayerObserver {
    private unowned let controller: PrivateMediaPlayerObserverRule?
    
    init(controller: PrivateMediaPlayerObserverRule) {
        self.controller = controller
    }
    
    func checkKey(object: Any?, key: String?, playerItem: AVPlayerItem?) {
        if let item = object as? AVPlayerItem, let keyPath = key, item == playerItem {
            
            switch keyPath {
            case "status":
                if controller?.getPlayerStatus() == AVPlayer.Status.readyToPlay {
                    controller?.playbackLikelyToKeepUpReady()
                } else if controller?.getPlayerStatus() == AVPlayer.Status.failed {
                    print("status: Failed")
                }
            case "playbackBufferEmpty":
                break
            case "playbackLikelyToKeepUp":
                if item.isPlaybackLikelyToKeepUp == true {
                    controller?.playbackLikelyToKeepUpReady()
                } else {
                    controller?.playbackLikelyToKeepUpLoading()
                }
            case "duration":
                let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                let duration = Double(item.duration.seconds)
                controller?.doUpdateDuration(duration: duration)
                controller?.setTimeObserver(interval: interval)
//                let interval1 = CMTimeMake(value: 1, timescale: 1)
                controller?.setBufferObserver()
            case "loadedTimeRanges":
//                 let interval1 = CMTimeMake(value: 1, timescale: 1)
                controller?.setBufferObserver()
            default:
                break
            }
        }
    }
    
    func checkPlayerItem(item: AVPlayerItem?, task: DoOnObserver) {
        if task == .AddObserver {
            guard let getPlayerItem = item else {
                print("Failed add notification, AVPlayerItem empty")
                controller?.errorObserver(message: PlayerError.AVPlayerItemEmpty)
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

//add media player info (lock screen)

