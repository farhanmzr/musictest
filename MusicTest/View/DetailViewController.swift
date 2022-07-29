//
//  DetailViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 15/07/22.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    var track: Track?
    
    
    var tapCloseButtonActionHandler : (() -> Void)?
    
    var currentState: State = .Stop
    var duration = 0.0
    
    private var sliderThumbWidth:CGFloat?
    private var bufferIndicator:UIView?
    
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
      label.textColor = .lightGray
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      label.numberOfLines = 1
      return label
    }()
    
    lazy var currentDurationSong: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.text = "00:00"
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
      label.numberOfLines = 1
      return label
    }()
    
    lazy var sliderProgressBar: UISlider = {
       let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.red
        slider.maximumTrackTintColor = UIColor.lightGray
        slider.addTarget(self, action: #selector(seeking), for: .touchUpInside)
        return slider
    }()
    
    lazy var durationSong: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.text = "00:00"
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
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.setTitle("Play", for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10)
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(clickStateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.hidesWhenStopped = true
      activityIndicator.style = .large
      return activityIndicator
    }()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let effect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: effect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
        setupView()
        setupActivityIndicator()
        guard let track = track else {
            return
        }
        titleLabel.text = track.title
        artistLabel.text = track.artist
        albumLabel.text = track.album
        
//        SongEngine.sharedInstance.updateState = { [weak self] status in
//            //karena self valuenya optional
//            guard let superself = self else {return}
//            superself.currentState = status
//        }
        
        SongEngine.sharedInstance.songDelegate = self
        
    }
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupView(){
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addSubview(artistLabel)
        NSLayoutConstraint.activate([
            artistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            artistLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addSubview(albumLabel)
        NSLayoutConstraint.activate([
            albumLabel.topAnchor.constraint(equalTo: artistLabel.bottomAnchor, constant: 12),
            albumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        view.addSubview(currentDurationSong)
        NSLayoutConstraint.activate([
            currentDurationSong.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 16),
            currentDurationSong.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24)
        ])
        view.addSubview(durationSong)
        NSLayoutConstraint.activate([
            durationSong.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 16),
            durationSong.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        //setup slider
        view.addSubview(sliderProgressBar)
        NSLayoutConstraint.activate([
            sliderProgressBar.topAnchor.constraint(equalTo: albumLabel.bottomAnchor, constant: 12),
            sliderProgressBar.leadingAnchor.constraint(equalTo: currentDurationSong.trailingAnchor, constant: 8),
            sliderProgressBar.trailingAnchor.constraint(equalTo: durationSong.leadingAnchor, constant: -8)
        ])
        
        //button
        view.addSubview(stateButton)
        NSLayoutConstraint.activate([
            stateButton.topAnchor.constraint(equalTo: currentDurationSong.bottomAnchor, constant: 32),
            stateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc func clickStateButton(){
        
        guard let track = track else {
            return
        }
        
        if currentState == .Stop {
            SongEngine.sharedInstance.setSong(item: track)
            SongEngine.sharedInstance.play()
        } else if currentState == .Pause {
            SongEngine.sharedInstance.play()
        } else if currentState == .Playing {
            SongEngine.sharedInstance.pause()
        }
        
    }
    
    @objc func seeking(){
        
        SongEngine.sharedInstance.seek(duration: duration, slider: sliderProgressBar.value)
        
    }
    
}

extension DetailViewController: SongDelegate {
    
    func updateState(state: State) {
        currentState = state
        if state == .Playing {
            stateButton.setTitle("Pause", for: .normal)
        }
        else if state == .Pause {
            stateButton.setTitle("Play", for: .normal)
        }
    }
    
    func updateProgresTime(time: Double) {
        let percentTime = (time / duration) * 100
        
        let minute = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let second = Int((time.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
        
        var minuteString = "00"
        var secondString = "00"
        
        if minute < 10 {
            minuteString = "0\(minute)"
        } else {
            minuteString = "\(minute)"
        }
        
        if second < 10 {
            secondString = "0\(second)"
        } else {
            secondString = "\(second)"
        }
        
        currentDurationSong.text = "\(minuteString):\(secondString)"
        
        sliderProgressBar.value = Float(percentTime)
        
        print("percent: \(percentTime)")
        
        print("progress: \(minuteString):\(secondString)")
    }
    
    func updateDuration(time: Double) {
        duration = time
        
        let minute = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let second = Int((time.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60))
        
        var minuteString = "00"
        var secondString = "00"
        
        if minute < 10 {
            minuteString = "0\(minute)"
        } else {
            minuteString = "\(minute)"
        }
        
        if second < 10 {
            secondString = "0\(second)"
        } else {
            secondString = "\(second)"
        }
        
        durationSong.text = "\(minuteString):\(secondString)"
        print("duration: \(Int(time.truncatingRemainder(dividingBy: 3600) / 60)):\(Int((time.truncatingRemainder(dividingBy: 3600)).truncatingRemainder(dividingBy: 60)))")
    }
    
    func updateBuffer(second: Double) {
        
        var frame = sliderProgressBar.frame
        
        guard let sliderThumbWidth = self.sliderThumbWidth else {
            return
        }
        
        let buffer = second / duration
        
        print("buffer: \(buffer)")
        
        let width = frame.size.width
        
        frame.origin.x = sliderProgressBar.frame.origin.x
        frame.size.width = CGFloat(buffer) * width
        
        let frameValue = frame
        
        bufferIndicator?.frame = frameValue
    }
}
