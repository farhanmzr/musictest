//
//  AlertExtensions.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import Foundation
import UIKit

extension UIViewController {
    
    func presentAlertOK(title: String?, message: String?, completion: @escaping (UIAlertAction) -> Void) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
      present(alert, animated: true)
    }
    
    func presentAlertAction(title: String?, message: String?, completion: @escaping (_ result: Bool) -> Void) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tidak", style: .cancel, handler: { action in
            completion(false)
        }))
      alert.addAction(UIAlertAction(title: "Ya", style: .default, handler: { action in
          completion(true)
      }))
      present(alert, animated: true)
    }
    
}
