//
//  QueueRules.swift
//  MusicTest
//
//  Created by Farhan Mazario on 04/08/22.
//

import Foundation

protocol QueueRules {
    func addQueue(track:[Track])
    func updateQueue()
    func checkState(state:PlayerState)
}
