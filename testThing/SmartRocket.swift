//
//  SmartRocket.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 1/1/2567 BE.
//

import SwiftUI
import AVFoundation
import Accelerate
import Charts

class AudioProcessing {
    static var shared: AudioProcessing = .init()
    
    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    
    let player = AVAudioPlayerNode()
    var fftMagnitudes: [Float] = []
    
    init() {
        _ = engine.mainMixerNode
        
        engine.prepare()
        try! engine.start()

        let audioFile = try! AVAudioFile(
            forReading: Bundle.main.url(forResource: "neon-gaming", withExtension: "mp3")!
        )
        let format = audioFile.processingFormat
            
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
            
        player.scheduleFile(audioFile, at: nil)
            
        let fftSetup = vDSP_DFT_zop_CreateSetup(
            nil,
            UInt(bufferSize),
            vDSP_DFT_Direction.FORWARD
        )
            
        engine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: UInt32(bufferSize),
            format: nil
        ) { [self] buffer, _ in
            let channelData = buffer.floatChannelData?[0]
            fftMagnitudes = fft(data: channelData!, setup: fftSetup!)
        }
    }
    func fft(data: UnsafeMutablePointer<Float>, setup: OpaquePointer) -> [Float] {
        var realIn = [Float](repeating: 0, count: bufferSize)
        var imagIn = [Float](repeating: 0, count: bufferSize)
        var realOut = [Float](repeating: 0, count: bufferSize)
        var imagOut = [Float](repeating: 0, count: bufferSize)
            
        for i in 0 ..< bufferSize {
            realIn[i] = data[i]
        }
        
        vDSP_DFT_Execute(setup, &realIn, &imagIn, &realOut, &imagOut)
        
        var magnitudes = [Float](repeating: 0, count: Constants.barAmount)
        
        realOut.withUnsafeMutableBufferPointer { realBP in
            imagOut.withUnsafeMutableBufferPointer { imagBP in
                var complex = DSPSplitComplex(realp: realBP.baseAddress!, imagp: imagBP.baseAddress!)
                vDSP_zvabs(&complex, 1, &magnitudes, 1, UInt(Constants.barAmount))
            }
        }
        
        var normalizedMagnitudes = [Float](repeating: 0.0, count: Constants.barAmount)
        var scalingFactor = Float(1)
        vDSP_vsmul(&magnitudes, 1, &scalingFactor, &normalizedMagnitudes, 1, UInt(Constants.barAmount))
            
        return normalizedMagnitudes
    }
}

struct SmartRocket: View {
    let audioProcessing = AudioProcessing.shared
    let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()

    @State var isPlaying = false
    @State var data: [Float] = Array(repeating: 0, count: Constants.barAmount)
        .map { _ in Float.random(in: 1 ... Constants.magnitudeLimit) }

    var body: some View {
        VStack{
            Chart(Array(data.enumerated()), id: \.0) { index, magnitude in
                BarMark(
                    x: .value("Frequency", String(index)),
                    y: .value("Magnitude", magnitude)
                )
                .foregroundStyle(
                    Color(
                        hue: 0.3 - Double((magnitude / Constants.magnitudeLimit) / 5),
                        saturation: 1,
                        brightness: 1,
                        opacity: 0.7
                    )
                )
            }
            .onReceive(timer, perform: updateData)
            .chartYScale(domain: 0 ... Constants.magnitudeLimit)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 100)
            .padding()
            .background(
                .black
                    .opacity(0.3)
                    .shadow(.inner(radius: 20))
            )
            .cornerRadius(10)

            playerControls
        }
    }
    var playerControls: some View {
        Group {
            ProgressView(value: 0.4)
                .tint(.secondary)
                .padding(.vertical)
            Text("Moonlight Sonata Op. 27 No. 2 - III. Presto")
                .font(.title2)
                .lineLimit(1)
            Text("Ludwig van Beethoven")
            
            HStack(spacing: 40) {
                Image(systemName: "backward.fill")
                Button(action: playButtonTapped) {
                    Image(systemName: "\(isPlaying ? "pause" : "play").circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                Image(systemName: "forward.fill")
            }
            .padding(10)
            .foregroundColor(.secondary)
        }
    }
    func updateData(_: Date) {
        if isPlaying {
            withAnimation(.easeOut(duration: 0.08)) {
                data = audioProcessing.fftMagnitudes.map {
                    min($0, Constants.magnitudeLimit)
                }
            }
        }
    }

    func playButtonTapped() {
        if isPlaying {
            audioProcessing.player.pause()
        } else {
            audioProcessing.player.play()
        }
        isPlaying.toggle()
    }
}


#Preview {
    SmartRocket()
//        .preferredColorScheme(.dark)
}
