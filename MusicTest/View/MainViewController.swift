//
//  MainViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 29/07/22.
//

import Foundation
import UIKit

class MainViewController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  // MARK: - Helpers
  private func setupViews() {
    tabBar.tintColor = .black
    tabBar.unselectedItemTintColor = .lightGray
    
    let homeNavigationController = UINavigationController(rootViewController: ViewController())
    homeNavigationController.title = "Home"
    homeNavigationController.tabBarItem.image = UIImage(named: "tabHomeUnselected")
    homeNavigationController.tabBarItem.selectedImage = UIImage(named: "tabHome")
    
    viewControllers = [
      homeNavigationController
    ]
  }
}
