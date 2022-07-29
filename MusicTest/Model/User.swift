//
//  User.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import Foundation

protocol DataUser{
    
    var username : String {set get}
    var password : String {set get}
    
}

struct User: DataUser {
    
    var username: String
    var password: String
    
}

