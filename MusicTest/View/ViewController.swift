//
//  ViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var contentView: UIView = {
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
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = true
        tv.isUserInteractionEnabled = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.hidesWhenStopped = true
//      activityIndicator.style = .large
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = false
        setupView()
        setupActivityIndicator()
//        configureHiddenVC()
    }
    
    func setupView() {
        title = "Home"
//        navigationController?.navigationBar.prefersLargeTitles = true   // iOS13
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          
          // di ganti karena support ke iOS 13 doang
          
          contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
          contentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        contentView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40)
        ])
        
        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 20),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        ])
        tableView.register(ViewTableCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      view.bringSubviewToFront(activityIndicator)
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func clickLogout(){
        UserDefaults.standard.removeObject(forKey: "is_authenticated")
        let viewController = LoginViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let track = tracks[indexPath.row]
        cell.textLabel?.text = track.title
        cell.detailTextLabel?.text = track.artist
        //for left image
//        cell.imageView?.image = UIImage(systemName: "play.circle.fill")
        
        // iOS 13
        if #available(iOS 13.0, *) {
            cell.accessoryView = UIImageView(image: UIImage(systemName: "play.circle.fill"))
        } else {
            // Fallback on earlier versions
        }

        return cell
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityIndicator.startAnimating()
        let vc = DetailViewController()
        vc.track = tracks[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        activityIndicator.stopAnimating()
    }
}


