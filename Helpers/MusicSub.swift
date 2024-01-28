//
//  MusicSub.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI

import SwiftUI
import AVFoundation
import Accelerate

class Music_Sub: NSObject{
    static let shared = Music_Sub()
    private var BackgroundSound1: AVAudioPlayer!
    private var BackgroundSound2: AVAudioPlayer!
    private var BackgroundSound3: AVAudioPlayer!
    private var BackgroundSound4: AVAudioPlayer!
    private var CurrentPlaying: AVAudioPlayer?
    
    override init() {
        super.init()
        ConfigureAudioSession()
        ConfigureMusic1()
        ConfigureMusic1()
        ConfigureMusic3()
        ConfigureMusic4()
    }
}
extension Music_Sub{
    private func ConfigureAudioSession(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    private func ConfigureMusic1(){
        let File = URL(fileURLWithPath: Bundle.main.path(forResource: "infinity-", ofType: "mp3")!)
        do {
            BackgroundSound1 = try AVAudioPlayer(contentsOf: File)
            BackgroundSound1?.prepareToPlay()
            BackgroundSound1?.numberOfLoops = -1
        } catch {
            BackgroundSound1 = nil
            print(error.localizedDescription)
        }
        BackgroundSound1.numberOfLoops = -1
    }
    private func ConfigureMusic2(){
        let File = URL(fileURLWithPath: Bundle.main.path(forResource: "Hitman", ofType: "mp3")!)
        do {
            BackgroundSound2 = try AVAudioPlayer(contentsOf: File)
            BackgroundSound2?.prepareToPlay()
            BackgroundSound2?.numberOfLoops = -1
        } catch {
            BackgroundSound2 = nil
            print(error.localizedDescription)
        }
        BackgroundSound2.numberOfLoops = -1
    }
    private func ConfigureMusic3(){
        let File = URL(fileURLWithPath: Bundle.main.path(forResource: "gameMain", ofType: "mp3")!)
        do {
            BackgroundSound3 = try AVAudioPlayer(contentsOf: File)
            BackgroundSound3?.prepareToPlay()
            BackgroundSound3?.numberOfLoops = -1
        } catch {
            BackgroundSound3 = nil
            print(error.localizedDescription)
        }
        BackgroundSound3.numberOfLoops = -1
    }
    private func ConfigureMusic4(){
        let File = URL(fileURLWithPath: Bundle.main.path(forResource: "neon-gaming", ofType: "mp3")!)
        do {
            BackgroundSound4 = try AVAudioPlayer(contentsOf: File)
            BackgroundSound4?.prepareToPlay()
            BackgroundSound4?.numberOfLoops = -1
        } catch {
            BackgroundSound4 = nil
            print(error.localizedDescription)
        }
        BackgroundSound4.numberOfLoops = -1
    }/*
    func toggleMusic(){
        if BackgroundSound1!.isPlaying{
            BackgroundSound1!.pause()
        }
        else {
            BackgroundSound1!.play()
        }
    }*/
    func playMusic1(){
        CurrentPlaying?.stop()
        BackgroundSound1!.play()
        CurrentPlaying = BackgroundSound1
    }
    func playMusic2(){
        CurrentPlaying?.stop()
        BackgroundSound2!.play()
        CurrentPlaying = BackgroundSound2
    }
    func playMusic3(){
        CurrentPlaying?.stop()
        BackgroundSound3!.play()
        CurrentPlaying = BackgroundSound3
    }
    func playMusic4(){
        CurrentPlaying?.stop()
        BackgroundSound4!.play()
        CurrentPlaying = BackgroundSound4
    }
    func pauseMusic(){
        //BackgroundSound1!.pause()
        //BackgroundSound2!.pause()
        CurrentPlaying?.pause()
    }
    func setVolumeForMusic1(_ volume: Float) {
        BackgroundSound1?.volume = volume
    }

    func setVolumeForMusic2(_ volume: Float) {
        BackgroundSound2?.volume = volume
    }
    func setVolumeForMusic3(_ volume: Float) {
        BackgroundSound3?.volume = volume
    }
    func setVolumeForMusic4(_ volume: Float) {
        BackgroundSound4?.volume = volume
    }
}

struct MusicSub: View {
    
    @State private var volume: Float = 0.5
    @State private var musicVolume1: Float = 0.5
    @State private var musicVolume2: Float = 0.5
    @State private var musicVolume3: Float = 0.5
    @State private var musicVolume4: Float = 0.5
    @Binding var status: Int
    
    var body: some View {
        VStack{
            HStack{
                Button{
                    Music_Sub.shared.playMusic1()
                } label: {
                    Text("EndGame")
                        .frame(width: 100)
                }
                Slider(value: $musicVolume1, in: 0...1, step: 0.1){
                    Text("volume1")
                } onEditingChanged: { _ in
                    Music_Sub.shared.setVolumeForMusic1(musicVolume1)
                }.frame(width: 200)
            }
            HStack{
                Button{
                    Music_Sub.shared.playMusic2()
                } label: {
                    Text("MainGame")
                        .frame(width: 100)
                }
                Slider(value: $musicVolume2, in: 0...1, step: 0.1){
                    Text("volume2")
                } onEditingChanged: { _ in
                    Music_Sub.shared.setVolumeForMusic2(musicVolume2)
                }.frame(width: 200)
            }
            HStack{
                Button{
                    Music_Sub.shared.playMusic3()
                } label: {
                    Text("Testing")
                        .frame(width: 100)
                }
                Slider(value: $musicVolume3, in: 0...1, step: 0.1){
                    Text("volume3")
                } onEditingChanged: { _ in
                    Music_Sub.shared.setVolumeForMusic3(musicVolume3)
                }
                .frame(width: 200)
            }
            HStack{
                Button{
                    Music_Sub.shared.playMusic4()
                } label: {
                    Text("Testing2")
                        .frame(width: 100)
                }
                Slider(value: $musicVolume4, in: 0...1, step: 0.1){
                    Text("volume4")
                } onEditingChanged: { _ in
                    Music_Sub.shared.setVolumeForMusic4(musicVolume4)
                }
                .frame(width: 200)
            }
            
            Button{
                Music_Sub.shared.pauseMusic()
            } label: {
                Text("stop music")
            }
            
            
            Button{
                status = 4
            } label: {
                Text("Back")
                    .padding(.bottom,10)
            }
            
        }
        .padding()
    }
}


#Preview {
    MusicSub(status: .constant(0))
}
