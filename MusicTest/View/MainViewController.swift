//
//  MainViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 29/07/22.
//

import UIKit

class MainViewController: UITabBarController {
    
    private var track: Track?
    
    var currentState: State?

    static var minHeight: CGFloat {
        return DeviceType.current.isIphoneXClass ? 83 : 50
    }
    static var maxHeight: CGFloat {
        return DeviceType.current.isIphoneXClass ? 125 : 100
    }
    
    private let hiddenVC: UIViewController = {
        let vc = DetailViewController()
        return vc
    }()
    
    lazy var miniPlayerView: LineView = {
        let lv = LineView()
        lv.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        lv.translatesAutoresizingMaskIntoConstraints = false
        return lv
    }()
    
    private lazy var titleLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
      label.numberOfLines = 1
      return label
    }()
    
    private lazy var artistLabel: UILabel = {
      let label = UILabel()
      label.textColor = .black
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
      label.numberOfLines = 1
      return label
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapPlayPauseButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var miniPlayerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapMiniPlayerButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupMiniPlayer()
        checkPlay()
        configureHiddenVC()
        
        (hiddenVC as? DetailViewController)?.sendTrackInfo = { [weak self] track in
            guard let superself = self else {return}
            superself.track = track
            superself.titleLabel.text = track.title
            superself.artistLabel.text = track.artist
            superself.checkPlay()
            superself.tapMiniPlayerButton()
        }
        
//        QueueEngine.sharedInstance.updateState = { [weak self] state in
//            //karena self valuenya optional
//            guard let superself = self else {return}
//            superself.currentState = state
//            print("main state \(superself.currentState)")
//            if state == .Playing {
//                superself.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
//            }
//            else if state == .Pause || state == .Stop {
//                superself.playPauseButton.setImage(UIImage(named: "play.fill"), for: .normal)
//            }
//        }
        
        (hiddenVC as? DetailViewController)?.sendState = { [weak self] state in
            guard let superself = self else {return}
            superself.currentState = state
            if state == .Playing {
                superself.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            }
            else if state == .Pause || state == .Stop {
                superself.playPauseButton.setImage(UIImage(named: "play.fill"), for: .normal)
            }
        }
        
//        SongEngine.sharedInstance.getSong = { [weak self] track in
//            guard let superself = self else {return}
//            superself.track = track
//            superself.titleLabel.text = track.title
//            superself.artistLabel.text = track.artist
//            superself.tapMiniPlayerButton()
//        }
    }
    
    private func checkPlay(){
        
        let isAlreadyShow = UserDefaults.standard.bool(forKey: "alreadyPlaying")
        
        if isAlreadyShow {
            miniPlayerView.isHidden = false
            miniPlayerButton.isHidden = false
            print("show")
        } else {
            miniPlayerView.isHidden = true
            miniPlayerButton.isHidden = true
            print("mini player hide")
        }
    }
    
    private func configureHiddenVC() {
        view.addSubview(hiddenVC.view)
    }
    
    private func setupTabBar() {
        
        tabBar.tintColor = .black
        tabBar.unselectedItemTintColor = .lightGray
        
        let homeNavigationController = UINavigationController(rootViewController: ViewController())
        homeNavigationController.title = "Home"
        homeNavigationController.tabBarItem.image = UIImage(named: "music.note.house")
        homeNavigationController.tabBarItem.selectedImage = UIImage(named: "music.note.house.fill")
        let homeVC = homeNavigationController.viewControllers.first as? ViewController
        
        
        let profileNavigationController = UINavigationController(rootViewController: ProfileViewController())
        profileNavigationController.title = "Profile"
        profileNavigationController.tabBarItem.image = UIImage(named: "person")
        profileNavigationController.tabBarItem.selectedImage = UIImage(named: "person.fill")
        
        self.setViewControllers([homeNavigationController, profileNavigationController], animated: false)
    }
    
    private func setupMiniPlayer(){
        view.addSubview(miniPlayerView)
        NSLayoutConstraint.activate([
            miniPlayerView.heightAnchor.constraint(equalToConstant: 44),
            miniPlayerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
            miniPlayerView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            miniPlayerView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        //add stack view as subview to main view with AutoLayout
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor, constant: 24),
            stackView.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor)
        ])
        
        view.addSubview(miniPlayerButton)
        NSLayoutConstraint.activate([
            miniPlayerButton.topAnchor.constraint(equalTo: miniPlayerView.topAnchor),
            miniPlayerButton.bottomAnchor.constraint(equalTo: miniPlayerView.bottomAnchor),
            miniPlayerButton.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor),
            miniPlayerButton.trailingAnchor.constraint(equalTo: miniPlayerView.trailingAnchor)
        ])
        
        view.addSubview(playPauseButton)
        NSLayoutConstraint.activate([
            playPauseButton.topAnchor.constraint(equalTo: miniPlayerButton.topAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: miniPlayerButton.bottomAnchor),
            playPauseButton.trailingAnchor.constraint(equalTo: miniPlayerButton.trailingAnchor, constant: -24)
        ])
    }
    
    @objc func tapPlayPauseButton() {
        if currentState == .Playing {
            SongEngine.sharedInstance.pause()
        } else if currentState == .Pause {
            SongEngine.sharedInstance.play()
        }
    }
    
    @objc func tapMiniPlayerButton() {
        (hiddenVC as? DetailViewController)?.maximizePanelController(animated: true, duration: 0.5, completion: nil)
    }
    
}
