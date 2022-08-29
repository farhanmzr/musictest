//
//  LoginViewController.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    var loginServices: Abstract = LoginServices()
    var user: User?
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        return label
    }()
        
    private lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Username"
        tf.borderStyle = .bezel
        tf.textColor = UIColor.black
        tf.backgroundColor = UIColor(white: 0, alpha: 0.0)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
        
    private lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.borderStyle = .bezel
        tf.textColor = UIColor.black
        tf.backgroundColor = UIColor(white: 0, alpha: 0.0)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor.lightGray
        button.addTarget(self, action: #selector(clickLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
      let activityIndicator = UIActivityIndicatorView()
      activityIndicator.hidesWhenStopped = true
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//      activityIndicator.style = .large  //iOS13
      return activityIndicator
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        
        self.tabBarController?.tabBar.isHidden = false
        setupTextFields()
        setupActivityIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if UserDefaults.standard.bool(forKey: "is_authenticated"){
            let viewcontroller = MainViewController()
            viewcontroller.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(viewcontroller, animated: true)
        }
    }
    
    
    private func setupActivityIndicator() {
      view.addSubview(activityIndicator)
      view.bringSubviewToFront(activityIndicator)
      activityIndicator.translatesAutoresizingMaskIntoConstraints = false
      activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
      activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setupTextFields() {
        
        let stackView = UIStackView(arrangedSubviews: [loginLabel, usernameTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        //add stack view as subview to main view with AutoLayout
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalToConstant: 240),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // diganti karena yg sebelumnya cuma support iOS13
            
            stackView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
        //visual format constraint
        
    }
    
    @objc func handleTextChange() {
            
        let usernameText = usernameTextField.text!
        let passwordText = passwordTextField.text!
            
        let isFormFilled = !usernameText.isEmpty && !passwordText.isEmpty
            
        if isFormFilled {
            loginButton.backgroundColor = UIColor.systemBlue
            loginButton.isEnabled = true
        } else {
            loginButton.backgroundColor = UIColor.lightGray
            loginButton.isEnabled = false
        }
            
    }
    
    @objc func clickLogin() {
        
        guard let usernameText = usernameTextField.text, !usernameText.isEmpty else { return }
        guard let passwordText = passwordTextField.text, !passwordText.isEmpty else { return }
        
        startLogin(username: usernameText, password: passwordText)
    }
    
    func startLogin(username: String, password: String) {
        
        activityIndicator.startAnimating()
        loginServices.signInUser(username: username, password: password) { result in
            if result {
                self.activityIndicator.stopAnimating()
                let def = UserDefaults.standard
                def.set(true, forKey: "is_authenticated")
                def.synchronize()
                self.presentAlertOK(title: "Login Success", message: "You are now logging in this app.") { _ in
                    let viewcontroller = MainViewController()
                    //move root controller
                    let nav = UINavigationController(rootViewController: viewcontroller)
                    UIApplication.shared.windows.first?.rootViewController = nav
                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                    
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.presentAlertOK(title: "Login Error", message: "Sorry, something went wrong.") { _ in
                }
            }
        }
        
        
        
    }
    
    
    
}
