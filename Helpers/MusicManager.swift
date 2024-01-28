import SwiftUI
import Charts
import AVFoundation
import Accelerate

enum Constants {
    static let updateInterval = 0.03
    static let barAmount = 40
    static let magnitudeLimit: Float = 32
}

class Music_Manager: NSObject, ObservableObject{
    //static let shared = Music_Manager()
    static var shared: Music_Manager = .init()
    private var audioEngine: AVAudioEngine
    private var backgroundSound: AVAudioPlayerNode
    private var currentPlaying: AVAudioPlayerNode?
    var audioFile: AVAudioFile?

    private let engine = AVAudioEngine()
    private let bufferSize = 1024
    var fftMagnitudes: [Float] = []
    let player = AVAudioPlayerNode()
    
    @Published var NameMusic: Int = 0
    let listName : [String] = ["infinity-","Hitman","gameMain","neon-gaming"]
    
    @Published var trackVolumes: [String: Float] = [:]
    
    override init() {
        audioEngine = AVAudioEngine()
        backgroundSound = AVAudioPlayerNode()
        super.init()
        configureAudioSession()
        //configureMusicNodes()
        for track in listName {
            trackVolumes[track] = 1.0
        }
        
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
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    private func loadAudioFile(resourceName: String, type: String) -> AVAudioFile? {
        guard let fileURL = Bundle.main.url(forResource: resourceName, withExtension: type) else {
            print("Error: File not found.")
            return nil
        }
        do {
            return try AVAudioFile(forReading: fileURL)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            return nil
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

extension Music_Manager {
    func playMusic(trackIndex: Int) {
        let trackName = listName[trackIndex]
        guard let fileURL = Bundle.main.url(forResource: trackName, withExtension: "mp3"),
              let file = try? AVAudioFile(forReading: fileURL) else {
            print("Error: File not found.")
            return
        }
        currentPlaying?.stop()
        player.scheduleFile(file, at: nil, completionHandler: nil)
        player.volume = trackVolumes[trackName] ?? 1.0
        player.play()
        currentPlaying = player
    }
    func stopAllMusic() {
        player.stop()
        currentPlaying?.stop()
        currentPlaying = nil
    }
    func updateVolume(trackName: String, level: Float) {
        trackVolumes[trackName] = level
        if trackName == listName[NameMusic] {
            player.volume = level
        }
    }

}

struct MusicManager: View {
    @ObservedObject var model = Music_Manager()
    @Binding var status: Int
    
    let audioProcessing1 = Music_Manager.shared
    let timer = Timer.publish(
        every: Constants.updateInterval,
        on: .main,
        in: .common
    ).autoconnect()

    @State var isPlaying = false
    @State var currentlyPlayingIndex: Int? = nil
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
            
            ForEach(0..<model.listName.count, id: \.self) { index in
                Button(action: { playMusic(trackName: audioProcessing1.listName[index]) }) {
                    HStack(spacing: 20){
                        Text(audioProcessing1.listName[index])
                            .frame(width: 100)

                        Image(systemName: currentlyPlayingIndex == index && isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                        HStack {
                            Image(systemName: "speaker.fill")
                            Slider(value: Binding(
                                get: { model.trackVolumes[model.listName[index], default: 1.0] },
                                set: { newVolume in
                                    model.updateVolume(trackName: model.listName[index], level: newVolume)
                                }
                            ), in: 0...1)
                            .frame(width: 100, height: 10, alignment: .leading)
                        }.padding()
                    }
                }
                .padding()
            }

            .padding(10)
            Button(action: stopButtonTapped) {
                Text("Stop Music")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
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
    func updateData(_: Date) {
        if isPlaying {
            withAnimation(.easeOut(duration: 0.08)) {
                data = audioProcessing1.fftMagnitudes.map {
                    min($0, Constants.magnitudeLimit)
                }
            }
        }
    }
    func playMusic(trackName: String) {
        if let trackIndex = model.listName.firstIndex(of: trackName) {
            audioProcessing1.playMusic(trackIndex: trackIndex)
            currentlyPlayingIndex = trackIndex
            isPlaying = true
        }
    }

    func stopButtonTapped() {            audioProcessing1.stopAllMusic()
        isPlaying = false
    }
}

#Preview {
    MusicManager(status: .constant(0))
        .preferredColorScheme(.dark)
}
