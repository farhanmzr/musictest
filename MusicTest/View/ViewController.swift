//
//  ViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import UIKit
import ARNTransitionAnimator

class ViewController: UIViewController {
    
    private var animator : ARNTransitionAnimator?
    
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
    
    lazy var miniPlayerView: LineView = {
        let lv = LineView()
        lv.backgroundColor = UIColor.gray
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
    
    lazy var activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.hidesWhenStopped = true
      activityIndicator.style = .large
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        setupView()
        setupActivityIndicator()
        setupAnimator()
    }
    
    func setupView() {
        
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
          contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        
        contentView.addSubview(miniPlayerView)
        NSLayoutConstraint.activate([
            miniPlayerView.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            miniPlayerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            miniPlayerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            miniPlayerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        //add stack view as subview to main view with AutoLayout
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: miniPlayerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: miniPlayerView.centerYAnchor)
        ])
        titleLabel.text = "TITLE"
        artistLabel.text = "ARTIST"
        
//        contentView.addSubview(miniPlayerButton)
//        NSLayoutConstraint.activate([
//            miniPlayerButton.topAnchor.constraint(equalTo: miniPlayerView.topAnchor),
//            miniPlayerButton.bottomAnchor.constraint(equalTo: miniPlayerView.bottomAnchor),
//            miniPlayerButton.leadingAnchor.constraint(equalTo: miniPlayerView.leadingAnchor),
//            miniPlayerButton.trailingAnchor.constraint(equalTo: miniPlayerView.trailingAnchor)
//        ])
//        let color = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.3)
//        miniPlayerButton.setBackgroundImage(self.generateImageWithColor(color), for: .highlighted)
        
    }
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      view.bringSubviewToFront(activityIndicator)
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupAnimator() {
        let modalVC = DetailViewController()
        let animation = MusicPlayerTransitionAnimation(rootVC: self, modalVC: modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetView: modalVC.view, direction: .bottom)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }
        
        let gestureHandler = TransitionGestureHandler(targetView: self.miniPlayerView, direction: .top)
        gestureHandler.panCompletionThreshold = 15.0
        gestureHandler.panFrameSize = self.view.bounds.size

        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        modalVC.transitioningDelegate = self.animator
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        print("ViewController viewWillAppear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        print("ViewController viewWillDisappear")
    }
    
    @objc func clickLogout(){
        UserDefaults.standard.removeObject(forKey: "is_authenticated")
        let viewController = LoginViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tapMiniPlayerButton() {
        let modalVC = DetailViewController()
        modalVC.modalPresentationStyle = .overCurrentContext
        self.present(modalVC, animated: true, completion: nil)
    }
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
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
        cell.accessoryView = UIImageView(image: UIImage(systemName: "play.circle.fill"))

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


