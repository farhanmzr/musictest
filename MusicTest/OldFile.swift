//
//  OldFile.swift
//  MusicTest
//
//  Created by Farhan Mazario on 22/07/22.
//

import Foundation
import UIKit
import MediaPlayer

class OldFile: UIViewController {
    
    var track: Track?
    
    var currentState: State = .Stop
    
    //Use an AVPlayer
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
    lazy var titleLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
      label.numberOfLines = 1
      return label
    }()
    
    lazy var artistLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
      label.numberOfLines = 1
      return label
    }()
    
    lazy var albumLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      label.numberOfLines = 1
      return label
    }()
    
    lazy var stateButton: UIButton = {
        var button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.setTitle("Play", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(clickStateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.hidesWhenStopped = true
//      activityIndicator.style = .large
      return activityIndicator
    }()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        setupView()
        setupActivityIndicator()
        guard let track = track else {
            return
        }
        titleLabel.text = track.title
        artistLabel.text = track.artist
        albumLabel.text = track.album
        
        
    }
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    
//    private func play(){
//        player.play()
//        stateButton.setTitle("Pause", for: .normal)
//        setupNowPlaying(isPause: false)
//        setupRemoteCommandCenter()
//        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 1
//        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
//    }
//
//    private func pause(){
//        player.pause()
//        stateButton.setTitle("Play", for: .normal)
//        setupNowPlaying(isPause: true)
//        setupRemoteCommandCenter()
//        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyPlaybackRate] = 0
//        MPNowPlayingInfoCenter.default().nowPlayingInfo![MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
//    }
    
    private func setupView(){
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            // fix compatibility for iOS13
            titleLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        view.addSubview(artistLabel)
        NSLayoutConstraint.activate([
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            artistLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        view.addSubview(albumLabel)
        NSLayoutConstraint.activate([
            albumLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 16),
            albumLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        view.addSubview(stateButton)
        NSLayoutConstraint.activate([
            stateButton.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 16),
            stateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
    }
    
    @objc func clickStateButton(){
        
        guard let track = track else {
            return
        }
        
        if currentState == .Stop {
//            SongEngine.sharedInstance.setSong(url: track.url)
            SongEngine.sharedInstance.play()
            setupNowPlaying(isPause: true)
        } else if currentState == .Pause {
            SongEngine.sharedInstance.play()
            setupNowPlaying(isPause: true)
        } else if currentState == .Playing {
            SongEngine.sharedInstance.pause()
            setupNowPlaying(isPause: false)
        }
        
    }
    
    func setupNowPlaying(isPause: Bool) {
        // Define Now Playing Info
        guard let track = track else {
            return
        }

        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.album
        if let image = UIImage(named: "ic_profile") {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPause ? 1 : 0

        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    //handle notification
//    func setupNotifications() {
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleInterruption),
//                                       name: AVAudioSession.interruptionNotification,
//                                       object: nil)
//        notificationCenter.addObserver(self,
//                                       selector: #selector(handleRouteChange),
//                                       name: AVAudioSession.routeChangeNotification,
//                                       object: nil)
//    }
//
//    //handle when phone call come
//    @objc func handleInterruption(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
//            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
//                return
//        }
//
//        if type == .began {
//            print("Interruption began")
//            // Interruption began, take appropriate actions
//        }
//        else if type == .ended {
//            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
//                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
//                if options.contains(.shouldResume) {
//                    // Interruption Ended - playback should resume
//                    print("Interruption Ended - playback should resume")
//                    play()
//                } else {
//                    // Interruption Ended - playback should NOT resume
//                    print("Interruption Ended - playback should NOT resume")
//                }
//            }
//        }
//    }
//
//    //handle when
//    @objc func handleRouteChange(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
//            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
//                return
//        }
//        switch reason {
//        case .newDeviceAvailable:
//            let session = AVAudioSession.sharedInstance()
//            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
//                print("headphones connected")
//                DispatchQueue.main.sync {
//                    self.play()
//                }
//                break
//            }
//        case .oldDeviceUnavailable:
//            if let previousRoute =
//                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
//                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
//                    print("headphones disconnected")
//                    DispatchQueue.main.sync {
//                        self.pause()
//                    }
//                    break
//                }
//            }
//        default: ()
//        }
//    }
//
//    //downloadFile
//    func downloadFile(){
//        guard let track = track else {
//            return
//        }
//
//        if let audioUrl = URL(string: track.url) {
//
//            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
//            print(destinationUrl)
//
//            // to check if it exists before downloading it
//            if FileManager.default.fileExists(atPath: destinationUrl.path) {
//                print("The file already exists at path")
//                playDownloadSong(url: audioUrl)
//            // if the file doesn't exist
//            } else {
//
//            // you can use NSURLSession.sharedSession to download the data asynchronously
//            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
//                guard let location = location, error == nil else { return }
//                do {
//                    // after downloading your file you need to move it to your destination url
//                    try FileManager.default.moveItem(at: location, to: destinationUrl)
//                        print("File moved to documents folder")
//                    } catch let error as NSError {
//                        print(error.localizedDescription)
//                    }
//                }).resume()
//            }
//        }
//    }
//
//    func playDownloadSong(url: URL){
//
//            // then lets create your document folder url
//            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//
//            // lets create your destination file url
//            let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
//            let setupUrl = AVURLAsset(url: destinationUrl, options: [:])
//            playerItem = AVPlayerItem(asset: setupUrl)
//            player = AVPlayer(playerItem: playerItem)
//            guard let player = player else { return }
//            player.play()
//    }
    
}
