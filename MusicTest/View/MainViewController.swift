//
//  MainViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 29/07/22.
//

import UIKit

class MainViewController: UITabBarController {
    
    private var track: Track?
    
    static var minHeight: CGFloat {
        return DeviceType.current.isIphoneXClass ? 83 : 50
    }
    static var maxHeight: CGFloat {
        return DeviceType.current.isIphoneXClass ? 125 : 100
    }
    
    private lazy var hiddenVC: UIViewController = {
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
    
    private lazy var miniPlayerButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapMiniPlayerButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        checkPlay()
        configureHiddenVC()
        
        SongEngine.sharedInstance.getSong = { [weak self] track in
            guard let superself = self else {return}
            superself.track = track
            superself.titleLabel.text = track.title
            superself.artistLabel.text = track.artist
            superself.tapMiniPlayerButton()
        }
    }
    
    private func checkPlay(){
        
        let isAlreadyShow = UserDefaults.standard.bool(forKey: "alreadyPlaying")
        
        if isAlreadyShow {
            setupMiniPlayer()
            print("show")
        } else {
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
        
        self.setViewControllers([homeNavigationController], animated: false)
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
    }
    
    @objc func tapMiniPlayerButton() {
        (hiddenVC as? DetailViewController)?.maximizePanelController(animated: true, duration: 0.5, completion: nil)
    }
    
}
