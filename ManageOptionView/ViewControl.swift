//
//  BossTwo.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 7/1/2567 BE.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.size.width

class ViewControl: UIViewController {
    let waterWaveView = WaterWaveView()
    
    let dr: TimeInterval = 10.0
    var timer: Timer?
    @State private var showTemporaryView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(waterWaveView)
        waterWaveView.setupProgress(waterWaveView.progress)
        
        NSLayoutConstraint.activate([
            waterWaveView.widthAnchor.constraint(equalToConstant: screenWidth * 0.5),
            waterWaveView.heightAnchor.constraint(equalToConstant: screenWidth * 0.5),
            waterWaveView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            waterWaveView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { _ in
            let dr = CGFloat(1.0 / (self.dr/0.01))
            
            self.waterWaveView.progress += dr
            self.waterWaveView.setupProgress(self.waterWaveView.progress)
            
            print(self.waterWaveView.progress)
            if self.waterWaveView.progress >= 0.999 {
                self.timer?.invalidate()
                self.timer = nil
                self.showTemporaryView = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    self.waterWaveView.percentAnim()
                }
            }
        })
    }
}


/*
struct BossTwo: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}
*/
#Preview {
    ViewControl()
}
