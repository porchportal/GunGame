//
//  SettingView .swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 18/1/2567 BE.
//

import SwiftUI

struct SettingsView: View{
    @ObservedObject var scene = Game_Scene(size: CGSize(width: 750, height: 1335))
    @Binding var showingSettings: Bool
    @Binding var status : Int
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.white.opacity(0.04))
                .ignoresSafeArea(.all)
            ZStack{
                Rectangle()
                    .fill(Color.white.opacity(0.8))
                VStack{
                    Text("Setting View")
                        .bold()
                        .font(.system(size: 40))
                        .foregroundStyle(.black)
                    
                    Button("Resume Game") {
                        //print("Resume Game button tapped")
                        showingSettings = false
                        scene.resumeGame()
                        scene.isGamePaused = false
                    }
                    .font(.system(size:20))
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 14)
                    .background(Color.green.opacity(0.5))
                    .cornerRadius(20)
                    .shadow(color: Color(white: 1), radius: 10)
                    
                    Button("Exit") {
                        print("Exit button tapped")
                        scene.resetGame()
                        status = 1
                    }
                    .font(.system(size:20))
                    .foregroundStyle(.black)
                    .frame(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.height / 14)
                    .background(Color.green.opacity(0.5))
                    .cornerRadius(20)
                    .shadow(color: Color(white: 1), radius: 10)
                    .padding()
                }
            }
            .foregroundStyle(Color.white.opacity(0.05))
            .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.height / 2)
            .cornerRadius(12)
            .shadow(radius: 10)
        }
    }
}

#Preview {
    SettingsView( showingSettings: .constant(true), status: .constant(0))
        .preferredColorScheme(.dark)
}
