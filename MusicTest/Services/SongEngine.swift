//
//  SongEngine.swift
//  MusicTest
//
//  Created by Farhan Mazario on 19/07/22.
//

import Foundation
import MediaPlayer
import AVFoundation
import Alamofire

class SongEngine: NSObject, MediaPlayerSetupRules {
    
    var player: AVPlayer
    
    fileprivate var playerItem: AVPlayerItem? = nil
    private var isPlaying: State = .Stop {
        didSet {
            updateState?(isPlaying)
        }
    }
    private var track: Track?
    
    private var dict: [String:Any?]?
    
    private var playerObserver: SongPlayerObserverRule?
    
    private var timeObserver: Any?
    
    private var bufferObserver: Any?
    
    private var lastPlayedItem: AVPlayerItem? = nil
    
    private var presenterObserver: SongPlayerObserverPresenterRule?
    
    private var presenter: MediaPlayerPresenterRules?
    
    static var sharedInstance: SongRules = SongEngine()
    
    var updateState: ((State) -> ())?
    var playerError: ((Error) -> ())?
    
//    var getSong: ((Track) -> ())?
    var getProgresTime: ((Double) -> ())?
    var getUpdateDuration: ((Double) -> ())?
    var getUpdateBuffer: ((Double) -> ())?
    
    override init() {
        player = AVPlayer()
        super.init()
        presenter = MediaPlayerPresenter(controller: self)
        presenterObserver = SongEngineObserverPresenter(controller: self)
        
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        presenterObserver?.checkKey(object: object, key: keyPath, playerItem: playerItem)
    }
    
    override class func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("keyPath: \(keyPath ?? "")")
    }
    
}

extension SongEngine: SongRules {
    
    func setSong<T>(item: T) {
        guard let itemTrack = item as? Track else {return}
        track = itemTrack
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioUrl = URL(string: itemTrack.url)
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl!.lastPathComponent)
    
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path setsong")
            let setupUrl = AVURLAsset(url: destinationUrl, options: [:])
            playerItem = AVPlayerItem(asset: setupUrl)
            player = AVPlayer(playerItem: playerItem)
            
        // if the file doesn't exist
        } else {
            print("streaming")
            let setupUrl = AVURLAsset(url: URL(string: itemTrack.url)!, options: [:])
            let songUrl = AVPlayerItem(asset: setupUrl)
            playerItem = songUrl
            //explore when end song duration more
            player = AVPlayer(playerItem: songUrl)
        }
        isPlaying = .Loading
        registerObserver(item: playerItem)
        dict = ["player": player, "item": playerItem]
        setupRemoteCommandCenter()
    }
    
    @objc func itemDidPlayToEnd() {
        stop()
    }
    
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
        guard let track = track else {return}
        guard let dict = dict else {return}
        isPlaying = .Playing
        setupNowPlaying(state: false, dict: dict, track: track)
    }
    
    func stop() {
        player.pause()
        player.seek(to: .zero)
        isPlaying = .Stop
    }
    
    func pause() {
        player.pause()
        isPlaying = .Pause
        guard let track = track else {return}
        guard let dict = dict else {return}
        setupNowPlaying(state: true, dict: dict, track: track)
    }
    
    func seek(duration: Double, slider: Float) {
        
        let second = Double(Float((duration / 100)) * slider)
        let seekTime = CMTime(seconds: second, preferredTimescale: 1)
        
        isPlaying = .Seek
        player.pause()
        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .positiveInfinity, completionHandler: { [weak self] result in
            self?.presenter?.checkState_Seek(state: (self?.isPlaying)!)
        })
    }
    
    func togglePlayPause() {
        self.presenter?.toggle(state: isPlaying)
    }
    
}

extension SongEngine: RemoveFileSong {
    
    func removeFileSong(completion: (Bool) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let audioKitFilesFolder = documentsUrl.appendingPathComponent("CustomSongFilesFolder")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let customFileURLs = try FileManager.default.contentsOfDirectory(at: audioKitFilesFolder, includingPropertiesForKeys: nil, options: [])
            
            for fileURL in fileURLs where fileURL.pathExtension == "mp3" {
                try FileManager.default.removeItem(at: fileURL)
            }
            for customFileURL in customFileURLs where customFileURL.pathExtension == "mp3" {
                try FileManager.default.removeItem(at: customFileURL)
            }
            completion(true)
        } catch  {
            completion(false)
            print(error)
        }
    }
    
    
}

extension SongEngine: DownloadFileSong {
    
    func downloadCustomFolderSong(urlSong: String) {
        if let audioUrl = URL(string: urlSong) {
        
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let audioKitFilesFolder = documentsDirectoryURL.appendingPathComponent("CustomSongFilesFolder")
            // lets create your destination file url
            do {
                try FileManager.default.createDirectory(atPath: audioKitFilesFolder.path, withIntermediateDirectories: true, attributes: nil)
                
                let destinationUrl = audioKitFilesFolder.appendingPathComponent(audioUrl.lastPathComponent)
                print(destinationUrl)
                
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    print("The file already exists at path when download")
                // if the file doesn't exist
                } else {
                    let destination: DownloadRequest.Destination = { _, _ in
                        return (destinationUrl, [.removePreviousFile])
                    }
                    AF.download(audioUrl, to: destination)
                    .downloadProgress { progress in
                        print("Download Progress: \(progress.fractionCompleted)")
                    }
                    .response { response in
                        if response.error == nil {
                            print("Success Download")
                        } else {
                            print(response.error?.errorDescription)
                        }
                    }
                }
            } catch let error as NSError {
                print("Error creating directory: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadFileSong(track: Track) {
        if let audioUrl = URL(string: track.url) {
        
            // then lets create your document folder url
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
            // lets create your destination file url
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            print(destinationUrl)
            
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("The file already exists at path when download")
            // if the file doesn't exist
            } else {
                let destination: DownloadRequest.Destination = { _, _ in
                    return (destinationUrl, [.removePreviousFile])
                }
                AF.download(audioUrl, to: destination)
                .downloadProgress { progress in
                    print("Download Progress: \(progress.fractionCompleted)")
                }
                .response { response in
                    if response.error == nil {
                        print("Success Download")
                    } else {
                        print(response.error?.errorDescription)
                    }
                }
            }
        }
    }
    
}

extension SongEngine: MediaPlayerInfoCenter {
    
    func setupNowPlaying(state: Bool, dict: [String:Any?], track: Track){
        guard let player = dict["player"] as? AVPlayer else {return}
        guard let item = dict["item"] as? AVPlayerItem else {return}
        
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.album
        if let image = UIImage(named: "ic_profile") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = state ? 0 : 1
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        if #available(iOS 13.0, *) {
            MPNowPlayingInfoCenter.default().playbackState = .playing
        } else {
            // Fallback on earlier versions
        }
    }
}

extension SongEngine: MediaPlayerCommandCenterRule {
    func setupRemoteCommandCenter() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.pause()
            return .success
        }
        commandCenter.togglePlayPauseCommand.isEnabled = true
    }
}

extension SongEngine: PrivateMediaPlayerRules {
    func doPlay() {
        self.play()
    }
    
    func doPause() {
        self.pause()
    }
    
    func doReplaceCurrentItem() {
        player.replaceCurrentItem(with: playerItem)
    }
    
    func errorInfo(message error: Error) {
        playerError?(error)
    }
}

fileprivate final class MediaPlayerPresenter: MediaPlayerPresenterRules {
    
    private unowned let controller: PrivateMediaPlayerRules?
    
    init(controller: PrivateMediaPlayerRules) {
        self.controller = controller
        
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            if #available(iOS 11.0, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            } else {
                // Fallback on earlier versions
                try  AVAudioSession.sharedInstance().setCategory(.playback)
            }
        } catch let error {
            print("AVAudioSession error: \(error)")
            controller.errorInfo(message: error)
        }
    }
    
    func checkState_Seek(state: State) {
        if state != .Pause {
            self.controller?.doPlay()
        }
    }
    
    func toggle(state: State) {
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

extension SongEngine: SongPlayerObserverRule {
    func registerObserver(item: AVPlayerItem?) {
        presenterObserver?.checkPlayerItem(item: lastPlayedItem, task: .RemoveObserver)
        lastPlayedItem = item
        presenterObserver?.checkPlayerItem(item: item, task: .AddObserver)
    }
    
}

extension SongEngine: PrivateSongPlayerObserverRule {
    func getPlayerStatus() -> AVPlayer.Status {
        return player.status
    }
    
    func playbackLikelyToKeepUp_loading() {
        isPlaying = .Loading
    }
    
    func playbackLikelyToKeepUp_ready() {
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
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] time in
            //do time update
            self?.getProgresTime?(time.seconds)
            //update time media info here
            MPNowPlayingInfoCenter.default().nowPlayingInfo?.updateValue(time.seconds, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
            if #available(iOS 13.0, *) {
                MPNowPlayingInfoCenter.default().playbackState = .playing
            } else {
                // Fallback on earlier versions
            }
        })
    }
    
    func setBufferObserver() {
        
        if let bufferValue = player.currentItem?.loadedTimeRanges.last?.timeRangeValue.end.seconds {
            getUpdateBuffer?(bufferValue)
        }
        else {
            print("buffer still empty")
            getUpdateBuffer?(0)
        }
    }
    
    func doUpdateDuration(duration: Double) {
        //totalTime
        getUpdateDuration?(duration)
    }
    
}


