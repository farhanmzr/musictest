//
//  QueueEngine.swift
//  MusicTest
//
//  Created by Farhan Mazario on 03/08/22.
//

import Foundation
import UIKit

class QueueEngine {
    
    private var view: DetailViewController? = nil
    
    static var sharedInstance: QueueRules = QueueEngine()
    
    private var musicPlayer: SongRules = SongEngine.sharedInstance
    private var filesPlayer: FilesRules = FilesEngine.sharedInstance
    private var cachingEngine: CachingRules = CachingEngine.sharedInstance
    
    private var currentState: State = .Stop
    
    private var isPlaying: State = .Stop {
        didSet {
            updateState?(isPlaying)
        }
    }
    
    private var listAntrian: [Track] = []
    private var currentIndex:Int = 0
    
    private var duration:Double = 0.0
    private var timeProgress:Double = 0.0
    
    var getSong: ((Track) -> ())?
    
    var getProgresTime: ((Double) -> ())?
    var getUpdateDuration: ((Double) -> ())?
    var getUpdateBuffer: ((Double) -> ())?
    var playerError: ((Error) -> ())?
    var updateState: ((State) -> Void)?
    var getNowPlaying: ((Track) -> ())?
    
    var removeCustomFilesSong: ((ResultProgress) -> ())?
    var removeFilesSong: ((ResultProgress) -> ())?

    
    init() {
        
        musicPlayer.getUpdateDuration = { [weak self] duration in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.getUpdateDuration?(duration)
            strongSelf.duration = duration
            
        }
        
        musicPlayer.getProgresTime = { [weak self] timeElapsed in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.getProgresTime?(timeElapsed)
            strongSelf.timeProgress = timeElapsed
        }
        
        musicPlayer.updateState = { [weak self] state in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.currentState = state
            
            if strongSelf.currentState == .Stop || state == .Pause {
                if state == .Stop {
                    
                    if (strongSelf.timeProgress / strongSelf.duration) >= 0.99 {
                        print("player finish")
                        self?.moveAutoNextQueue()
                        print(QueueTemp.queue)
                    }
                    print("player stop")
                }
            }
            strongSelf.updateState?(state)
        }
    }
}

extension QueueEngine: QueueRules {
    
    //init dispatchgroup -> handle 2 proses bisa jalan bareng
    //didalem removefilesong closure ada proses lanjut removecustomfile
    //ada closure baru ketika udh selesai
    func removeSong() {
        cachingEngine.removeFileSong { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            strongSelf.removeFilesSong?(result)
        }
        
        filesPlayer.removeCustomFileSong { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            strongSelf.removeCustomFilesSong?(result)
        }
    }
    
    func downloadFileSong(track: Track) {
        CachingEngine.sharedInstance.downloadFileSong(track: track)
    }
    
    func downloadCustomFileSong(track: Track) {
        FilesEngine.sharedInstance.downloadCustomFolderSong(track: track)
    }
    
    func addQueue(track: [Track], index: Int) {
        
        listAntrian = track
        currentIndex = index
        
        let nowMusic = listAntrian[currentIndex]
        
        var temp = QueueTemp.queue
        temp.append(contentsOf: listAntrian)
        let getNew = temp.firstIndex(where: { $0.title == nowMusic.title })!
        let element = temp.remove(at: getNew)
        temp.insert(element, at: 0)
        QueueTemp.queue = temp
        
        musicPlayer.setSong(item: nowMusic)
        getSong?(nowMusic)
        getNowPlaying?(nowMusic)
        musicPlayer.play()
        
        if currentIndex < listAntrian.count {
            let nextMusic = listAntrian[currentIndex + 1]
            downloadFileSong(track: nextMusic)
        }
    }
    
    func moveAutoNextQueue() {
        
        let oldMusic = listAntrian[currentIndex]
        
        if currentIndex + 1 < listAntrian.count {
            
            currentIndex = currentIndex + 1
            
            print("currentIndexNext \(currentIndex)")
            
            let newMusic = listAntrian[currentIndex]
            var temp = QueueTemp.queue
            let getNew = temp.firstIndex(where: { $0.title == newMusic.title })!
            let element = temp.remove(at: getNew)
            temp.insert(element, at: 0)
            let getOld = temp.firstIndex(where: { $0.title == oldMusic.title })!
            let element2 = temp.remove(at: getOld)
            temp.insert(element2, at: temp.count)
            QueueTemp.queue = temp
            
            musicPlayer.setSong(item: newMusic)
            getSong?(newMusic)
            getNowPlaying?(newMusic)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.musicPlayer.play()
            })
            
            if currentIndex + 1 < listAntrian.count {
                let nextMusic = listAntrian[currentIndex + 1]
                downloadFileSong(track: nextMusic)
            }
            
        }
        
    }
    
    func moveNextQueue() {
        
        let oldMusic = listAntrian[currentIndex]
        
        if currentIndex + 1 < listAntrian.count {
            
            currentIndex = currentIndex + 1
            
            print("currentIndexNext \(currentIndex)")
            
            let newMusic = listAntrian[currentIndex]
            var temp = QueueTemp.queue
            let getNew = temp.firstIndex(where: { $0.title == newMusic.title })!
            let element = temp.remove(at: getNew)
            temp.insert(element, at: 0)
            let getOld = temp.firstIndex(where: { $0.title == oldMusic.title })!
            let element2 = temp.remove(at: getOld)
            temp.insert(element2, at: temp.count)
            QueueTemp.queue = temp
            
            musicPlayer.stop()
            musicPlayer.setSong(item: newMusic)
            getSong?(newMusic)
            getNowPlaying?(newMusic)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.musicPlayer.play()
            })
            
            if currentIndex + 1 < listAntrian.count {
                let nextMusic = listAntrian[currentIndex + 1]
                downloadFileSong(track: nextMusic)
            }
            
        }
        
    }
    
    func movePrevQueue() {
        
        let oldMusic = listAntrian[currentIndex]
        
        if currentIndex - 1 >= 0 {
            
            currentIndex = currentIndex - 1
            print("currentIndexPrev \(currentIndex)")
            
            let newMusic = listAntrian[currentIndex]
            var temp = QueueTemp.queue
            let getNew = temp.firstIndex(where: { $0.title == newMusic.title })!
            let element = temp.remove(at: getNew)
            temp.insert(element, at: 0)
            let getOld = temp.firstIndex(where: { $0.title == oldMusic.title })!
            let element2 = temp.remove(at: getOld)
            temp.insert(element2, at: temp.count)
            QueueTemp.queue = temp
            print(temp)
            print("temp kurang")
            
            musicPlayer.stop()
            musicPlayer.setSong(item: newMusic)
            getSong?(newMusic)
            getNowPlaying?(newMusic)
            musicPlayer.play()
            
            if currentIndex - 1 >= 0 {
                let nextMusic = listAntrian[currentIndex - 1]
                downloadFileSong(track: nextMusic)
            }
        }
        
    }
    
    func updateQueue() {
        
    }
    
    func checkState(state: State) {
        
    }
    
    
}
