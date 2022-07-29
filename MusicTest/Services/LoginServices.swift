//
//  LoginServices.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import Foundation

class LoginServices: Abstract {
    
//    static let shared: LoginServices = LoginServices()
//    private init() {}
    
    //<<<<SIGN IN USER>>>>
    func signInUser(username: String, password: String, completion: (_ result: Bool) -> Void) {
        let name = "Admin"
        let pw = "Admin"
        if name == username && pw == password {
            completion(true)
        } else {
            completion(false)
        }
    }
    
}

protocol Abstract {
    
    func signInUser(username: String, password: String, completion: (_ result: Bool) -> Void)
    
}
