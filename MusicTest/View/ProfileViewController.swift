//
//  ProfileViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 18/08/22.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {
    
    private lazy var contentView: UIView = {
      let contentView = UIView()
      contentView.translatesAutoresizingMaskIntoConstraints = false
      return contentView
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.systemBlue
        button.addTarget(self, action: #selector(clickLogout), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        setupView()
    }
    
    private func setupView(){
        
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
          contentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        contentView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40)
        ])
    }
    
    @objc func clickLogout(){
        
        //pake 1 closure
        QueueEngine.sharedInstance.removeFilesSong = { result in
            if result == .Success {
                SongEngine.sharedInstance.stop()
                UserDefaults.standard.removeObject(forKey: "is_authenticated")
                let viewController = LoginViewController()
                let nav = UINavigationController(rootViewController: viewController)
                UIApplication.shared.windows.first?.rootViewController = nav
                UIApplication.shared.windows.first?.makeKeyAndVisible()
            }
        }
        
        QueueEngine.sharedInstance.removeSong()
    }
    
}
