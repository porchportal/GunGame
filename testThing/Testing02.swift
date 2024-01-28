//
//  Testing02.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI
import AVFoundation


class MusicPlayer {
    static let shared = MusicPlayer()
    var audioPlayer: AVAudioPlayer?

    func playMusic(musicName: String) {
        if let bundlePath = Bundle.main.path(forResource: musicName, ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: bundlePath))
                audioPlayer?.play()
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    func stopMusic() {
        audioPlayer?.stop()
    }
}

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMusicButton()
        setupMusicstop()
    }
    
    func setupMusicButton() {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Play Music 1", for: .normal)
        button.addTarget(self, action: #selector(playMusicButtonTapped), for: .touchUpInside)
        self.view.addSubview(button)
    }
    func setupMusicstop() {
        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 100, height: 50))
        button.backgroundColor = .blue
        button.setTitle("Stop Music", for: .normal)
        button.addTarget(self, action: #selector(stopMusicButtonTapped), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func playMusicButtonTapped() {
        MusicPlayer.shared.playMusic(musicName: "gameMain")
    }
    @objc func stopMusicButtonTapped() {
        MusicPlayer.shared.stopMusic()
    }
}


#Preview {
    ViewController()
}
