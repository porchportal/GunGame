//
//  VictoryView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 13/1/2567 BE.
//

import SwiftUI

struct VictoryView: View {
    @ObservedObject var scene = Game_Scene(size: .zero)
    @Binding var status: Int
    var highScore: Int {
        UserDefaults.standard.integer(forKey: "HighScore")
    }
    var body: some View {
        ZStack{
            VStack{
                Spacer()
                VStack{
                    Text("Victory")
                        .font(.system(size: 50))
                        .font(.largeTitle)
                        .foregroundStyle(.green)
                        .shadow(color: .red, radius: 50, x: 0, y: 0)
                        .padding(20)
                        .background(Color.white.opacity(0.02))
                        .clipShape(.capsule)
                        .cornerRadius(20)
                        .padding()
                    //let shuffledTextElements = Textbully.shuffled()
                    HStack{
                        Text("Score = \(scene.score)")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(.capsule)
                            .cornerRadius(10)
                            .padding()
                        Text("High Score = \(highScore)")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.2))
                            .clipShape(.capsule)
                            .cornerRadius(10)
                            .padding()
                    }
                    Button{
                        status = 1
                        //scene.resetGame()
                    } label: {
                        Text("Back to Start")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.green.opacity(0.2))
                            .clipShape(.capsule)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .background(Image("image002")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.75)
                .edgesIgnoringSafeArea(.all))
        }
    }
}

#Preview {
    VictoryView(scene: Game_Scene(size: .zero), status: .constant(0))
        .preferredColorScheme(.dark)
}
