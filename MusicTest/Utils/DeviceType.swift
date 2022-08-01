//
//  DeviceType.swift
//  MusicTest
//
//  Created by Farhan Mazario on 01/08/22.
//

import Foundation
import UIKit

enum DeviceType {
    case iPhone5, iPhone6, iPhone6Plus, iPhoneX, iPhoneXR, iPhoneXSMax, iPad, unknown
    static var current: DeviceType {
        if UIDevice.current.userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                //"iPhone 5 or 5S or 5C"
                return .iPhone5
            case 1334:
                //"iPhone 6/6S/7/8"
                return .iPhone6
            case 2208:
                //"iPhone 6+/6S+/7+/8+"
                return .iPhone6Plus
            case 2436:
                // iPhone X, XS, 11 Pro
                return .iPhoneX
            case 2688:
                // iPhone XS Max, iPhone XS Max
                return .iPhoneXSMax
            case 1792:
                // iPhone XR, iPhone 11
                return .iPhoneXR
            default:
                return .unknown
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .unknown
        }
    }
    
    var isIphoneXClass: Bool {
        return self == .iPhoneX || self == .iPhoneXSMax || self == .iPhoneXR
    }
}
