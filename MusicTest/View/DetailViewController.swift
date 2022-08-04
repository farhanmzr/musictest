//
//  DetailViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 15/07/22.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    
    enum MusicPlayerViewControllerPanelState {
        case isMaximize
        case isMinimize
        case isClosed
    }
    
    fileprivate let fullView: CGFloat = 0
    fileprivate var partialView: CGFloat {
        return UIScreen.main.bounds.height
    }
    fileprivate var panelState: MusicPlayerViewControllerPanelState = .isClosed
    
    var track: Track?
    var currentState: State = .Stop
    var duration = 0.0
    
    var sendTrackInfo: ((Track) -> ())?
    
    private var sliderThumbWidth:CGFloat?
    private var bufferIndicator:UIView?
    
    private let btnClose: UIButton = {
        let button = UIButton()
        button.backgroundColor = .gray
        button.setTitle("X", for: .normal)
        return button
    }()
    
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
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            // Fallback on earlier versions
        }
      return activityIndicator
    }()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white  // diganti karena value backgroundColor cuma ada di iOS13
        setupView()
        setupActivityIndicator()
        closePanelController(animated: false, completion: nil) // fix music player tidak ke hide
        
        SongEngine.sharedInstance.getSong = { [weak self] track in
            guard let superself = self else {return}
            superself.track = track
            superself.titleLabel.text = track.title
            superself.artistLabel.text = track.artist
            superself.albumLabel.text = track.album
            print(track)
            superself.sendTrackInfo?(track)
        }
        
//        SongEngine.sharedInstance.updateState = { [weak self] status in
//            //karena self valuenya optional
//            guard let superself = self else {return}
//            superself.currentState = status
//        }
        
//        SongEngine.sharedInstance.songDelegate = self
        
        
    }
    
    func closePanelController(animated: Bool, completion: (() -> Void)?) {
        panelState = .isClosed
        view.alpha = 0
    }
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupView(){
        
        view.addSubview(btnClose)
        
        var constraints: [NSLayoutConstraint] = []
        
        btnClose.translatesAutoresizingMaskIntoConstraints = false
        
        constraints += [NSLayoutConstraint(item: btnClose, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 50)]
        constraints += [NSLayoutConstraint(item: btnClose, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50)]
        constraints += [NSLayoutConstraint(item: btnClose, attribute: .width, relatedBy: .equal, toItem: btnClose, attribute: .height, multiplier: 1, constant: 0)]
        constraints += [NSLayoutConstraint(item: btnClose, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
        btnClose.addTarget(self, action: #selector(minimizeThisPage), for: .touchDown)
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: btnClose.bottomAnchor, constant: 32),
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
    
    @objc private func minimizeThisPage() {
        self.minimizePanelController(animated: true, duration: 0.5, completion: nil)
    }
    
    @objc func clickStateButton(){
        
        let isAlreadyShow = UserDefaults.standard.bool(forKey: "alreadyPlaying")
        
        if !isAlreadyShow {
            let def = UserDefaults.standard
            def.set(true, forKey: "alreadyPlaying")
            def.synchronize()
            print("play")
        }
        
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

extension DetailViewController {
    
    func setViewClosePanel(frame: CGRect) {
        print("close frame: \(frame.height - MainViewController.minHeight)")
        self.view.frame = CGRect(x: 0, y: frame.height,
                                 width: frame.width, height: frame.height - MainViewController.minHeight)
        self.view.layoutIfNeeded()
        print("close frame result: \(self.view.frame)")
    }
    
    func setMinimizePanel(frame: CGRect) {
        self.view.frame = CGRect(x: 0, y: self.partialView,
                                 width: frame.width, height: frame.height)
        self.view.layoutIfNeeded()
        print("minimize frame result: \(self.view.frame)")
    }
    
    func setMaximizePanel(frame: CGRect) {
        self.view.frame = CGRect(x: 0, y: self.fullView,
                                 width: frame.width, height: frame.height)
        self.view.layoutIfNeeded()
        print("maximize frame result: \(self.view.frame)")
    }
    
    func closePanelMusicPlayer_WithAnimation(isFinish: @escaping (Bool)->()) {
        
        let frame = UIScreen.main.bounds
        
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.setViewClosePanel(frame: frame)
        }, completion: { isFinished in
            isFinish(isFinished)
        })
    }
    
    func maximizePanelMusicPlayer_withAnimation(frame: CGRect,duration: Double,isFinish: @escaping (Bool)->()) {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.setMaximizePanel(frame: frame)
        }, completion: { isFinished in
            isFinish(isFinished)
        })
    }
    
    func minimizePanelMusicPlayer_withAnimation(frame: CGRect, duration: Double, isFinish: @escaping (Bool)->()) {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0.0, options: [.allowUserInteraction], animations: {
            self.setMinimizePanel(frame: frame)
        }, completion: { isFinished in
            isFinish(isFinished)
        })
    }
    
    func maximizePanelController(animated: Bool, duration: Double, completion: (() -> Void)?){
        let frame = UIScreen.main.bounds
        view.alpha = 1
        if animated {
            maximizePanelMusicPlayer_withAnimation(frame: frame, duration: duration, isFinish: { isFinished in
                guard isFinished else {
                    return
                }
                self.setPanelState(state: .isMaximize)
                completion?()
            })
            
        }
        else {
            self.setMaximizePanel(frame: frame)
            self.setPanelState(state: .isMaximize)
            completion?()
        }
        
    }
    
    func minimizePanelController(animated: Bool, duration: Double, completion: (() -> Void)?){
        let frame = UIScreen.main.bounds
        view.alpha = 0
        if animated {
            minimizePanelMusicPlayer_withAnimation(frame: frame, duration: duration, isFinish: { isFinished in
                guard isFinished else {
                    return
                }
                self.setPanelState(state: .isMinimize)
                completion?()
            })
        } else {
            self.setMinimizePanel(frame: frame)
            self.setPanelState(state: .isMinimize)
            completion?()
        }
    }
    
    func setPanelState(state: MusicPlayerViewControllerPanelState) {
        panelState = state
    }
}

