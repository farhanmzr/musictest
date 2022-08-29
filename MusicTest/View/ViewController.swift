//
//  ViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import UIKit

class ViewController: UIViewController {
    
    // making this a weak variable so that it won't create a strong reference cycle
    
    private lazy var contentView: UIView = {
      let contentView = UIView()
      contentView.translatesAutoresizingMaskIntoConstraints = false
      return contentView
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
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      return activityIndicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupActivityIndicator()
        
        //closure return index row
        //reloadSpesificTable
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
          contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          contentView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
          contentView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        ])
        
        contentView.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
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
        
        let accessoryButton = UIButton(type: .custom)
        let action = #selector(btnDownloadTap(sender:event:))
            accessoryButton.addTarget(self, action: action, for: .touchUpInside)
        accessoryButton.setImage(UIImage(named: "save"), for: .normal)
            accessoryButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            accessoryButton.contentMode = .scaleAspectFit
        cell.accessoryView = accessoryButton as UIView
        
        return cell
    }
    
    @objc func btnDownloadTap(sender: UIButton?, event: UIEvent){
        let touches = event.allTouches
        let touch = touches!.first
        guard let touchPosition = touch?.location(in: self.tableView) else {
            return
        }
        if let indexPath = tableView.indexPathForRow(at: touchPosition) {
            tableView(self.tableView, accessoryButtonTappedForRowWith: indexPath)
        }
    }
}

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        QueueEngine.sharedInstance.addQueue(track: tracks, index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        QueueEngine.sharedInstance.downloadCustomFileSong(track: tracks[indexPath.row])
    }
}


