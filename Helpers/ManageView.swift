//
//  ManageView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 27/12/2566 BE.
//

import SwiftUI

struct ManageView: View {
    @ObservedObject var scene = Game_Scene(size: CGSize(width: 750, height: 1335))
    @State private var status: Int = 0
    //@Binding var musicVolume1: Float
    @State private var ContentActive: Bool = false
    
    var body: some View {
        ZStack{
            ZStack{
                switch status{
                case 0:
                    welcomeSection
                        .transition(.opacity)
                case 1:
                    StartView(status: $status, ContentActive: $ContentActive)
                        .onAppear{
                            //Music_Manager.shared.playMusic2()
                        }
                        .transition(.opacity)
                case 2:
                    ContentView(scene: scene, status: $status, ContentActive: $ContentActive)
                        .transition(.opacity)
                case 3:
                    EndingScene1(status: $status, ContentActive: $ContentActive)
                case 4:
                    OptionView(showTemporaryView: .constant(false), status: $status)
                        .transition(.opacity)
                //case 5:
                //    VictoryView(scene: scene, status: $status)
                case 6:
                    MusicManager(status: $status)
                default:
                    RoundedRectangle(cornerRadius: 30)
                        .foregroundStyle(.purple)
                        .transition(.opacity)
                }
            }
        }
    }
}
extension ManageView{
    private var buttom: some View{
        Text("Let's play")
            .font(.headline)
            .foregroundStyle(Color.white)
    }
    private var welcomeSection: some View{
        ZStack{
            Rectangle()
                .fill(Color.black)
                .edgesIgnoringSafeArea(.all)
            TextShimmer(text: "Welcome")
                .font(.custom("Chalkduster", size: 65))
                .padding()
                //.background(Color.white.opacity(0.6))
                .cornerRadius(30)
                .shadow(color: .white, radius: 20, x: 0, y: 0)
                .shadow(color: .blue, radius: 40, x: 0, y: 0)
                .shadow(color: .blue, radius: 60, x: 0, y: 0)
        }
        .onTapGesture {
            status = 1
        }
    }
}
struct TextShimmer: View{
    var text: String

    @State var animation = false
    
    //Random Color
    func randomColor() -> Color{
        let color = UIColor(red: CGFloat.random(in: 0...2),
                            green: CGFloat.random(in: 0...2), blue: 1, alpha: 1)
        return Color(color)
    }
    
    var body: some View{
        ZStack{
            Text(text)
                .font(.system(size: 45, weight: .bold))
                .foregroundColor(Color.black.opacity(0.85))
            
            // MutiColor
            HStack(spacing: 0){
                ForEach(0..<text.count, id: \.self){index in
                    Text(String(text[text.index(text.startIndex, offsetBy: index)]))
                        .font(.system(size: 45, weight: .bold))
                        .foregroundColor(randomColor())
                }
            }
            // masking for shimmer Effect
            .mask(
                Rectangle()
                    .fill(
                        LinearGradient(gradient: .init(colors: [Color.white.opacity(1.4), Color.green, Color.green.opacity(1.4)]), startPoint: .top, endPoint: .bottom)
                    )
                    .rotationEffect(.init(degrees: 70))
                    .padding(20)
                    //moving view continously
                    .offset(x: -250)
                    .offset(x: animation ? 500 : 0)
            )
            .onAppear(perform: {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)){
                    animation.toggle()
                }
            })
        }
    }
}

#Preview {
    ManageView()
        .preferredColorScheme(.dark)
}
