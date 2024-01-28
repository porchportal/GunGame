//
//  StartView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 21/12/2566 BE.
//

import SwiftUI
import SpriteKit

var shipChoice = UserDefaults.standard
struct StartView: View {
    @Binding var status :Int
    @State private var activeButton: Int? = nil
    @Binding var ContentActive: Bool
    var body: some View {
        NavigationView{
            ZStack {
                Image("IMG_1868")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.75)
                    .ignoresSafeArea()
                // Main content
                VStack(alignment: .center, spacing: 10) {
                    Spacer()
                    TextShimmer(text: "Space Shooter")
                        .foregroundStyle(Color.black)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(30)
                        .shadow(color: .black, radius: 20, x: 0, y: 4)
                    
                    Button{
                        self.ContentActive = true
                        self.status = 2
                    } label: {
                        Text("Start Game")
                            .foregroundColor(.black)
                            .font(.custom("Chalkduster", size: 30))
                            .padding()
                            .background(Color.green.opacity(0.5))
                            .clipShape(.capsule)
                            .cornerRadius(30)
                            .shadow(color: .red, radius: 10, x: 5, y: 5)
                    }
                    Button{
                        withAnimation{
                            self.status = 4
                        }
                    } label: {
                        Text("Option")
                            .foregroundColor(.black)
                            .font(.custom("Chalkduster", size: 30))
                            .padding()
                            .background(Color.gray.opacity(0.4))
                            .clipShape(.capsule)
                            .cornerRadius(30)
                            .shadow(color: .red, radius: 10, x: 5, y: 5)
                    }
                    .padding()
                    HStack{
                        Spacer()
                        VStack{
                            Text("Selection the Ship")
                            Button(action: {
                                makePlayerChoice()
                                withAnimation(.easeIn(duration: 0.5)) {
                                    activeButton = 0
                                }
                            }) {
                                buttonContent(title: "Ship(0)", id: 0)
                            }
                            Button(action: {
                                makePlayerChoice2()
                                withAnimation(.easeIn(duration: 0.5)) {
                                    activeButton = 1
                                }
                            }) {
                                buttonContent(title: "Ship(1)", id: 1)
                            }
                            Button(action: {
                                makePlayerChoice3()
                                withAnimation(.easeIn(duration: 0.5)) {
                                    activeButton = 2
                                }
                            }) {
                                buttonContent(title: "Ship(2)", id: 2)
                            }
                        }
                        Spacer()
                    }
                    .buttonStyle(ShipButtonStyle())
                    Spacer()
                }
                .padding()
            }
        }
        .transition(.asymmetric(insertion: .scale, removal: .opacity))
    }
    
    func makePlayerChoice(){
        shipChoice.set(1, forKey: "playerChoice")
    }
    func makePlayerChoice2(){
        shipChoice.set(2, forKey: "playerChoice")
    }
    func makePlayerChoice3(){
        shipChoice.set(3, forKey: "playerChoice")
    }
    private func buttonContent(title: String, id: Int) -> some View {
        HStack(spacing: 10) {
            Image(getShipImageName(for: id))
                .resizable()
                .frame(width: 40, height: 40)
                .cornerRadius(10)
            Text(title)
                .foregroundColor(.black)
                //.foregroundColor(activeButton == id ? .black : .primary)
            if activeButton == id {
                Image(systemName: "hand.thumbsup")
                    .foregroundColor(.green)
                    .scaleEffect(1.3)
            }
        }
        .frame(width: 180, height: 50) // Set the frame to your desired button size
        .background(activeButton == id ? Color.green.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .overlay(
            Circle()
                .strokeBorder(lineWidth: activeButton == id ? 0 : 0)
                .frame(width: 70, height: 70)
                .foregroundColor(Color(.systemPink))
                .hueRotation(.degrees(activeButton == id ? 0 : 200))
                .scaleEffect(activeButton == id ? 1.9 : 1)
                .offset(x: activeButton == id ? 65 : 0, y: 0), alignment: .trailing//35
        )
    }
    private func getShipImageName(for id: Int) -> String {
        switch id {
        case 0:
            return "Player.001"
        case 1:
            return "Player2.001"
        case 2:
            return "Boss"
        default:
            return "DefaultShipImage"
        }
    }
}
struct ShipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.black)
            .font(.system(size: 20, weight: .bold, design: .serif))
            //.padding()
            .background(configuration.isPressed ? .gray.opacity(0.02) : .gray.opacity(0.2))
            .shadow(color: .white, radius: 10, x: 5, y: 5)
            .clipShape(Capsule())

    }
}

#Preview {
    StartView(status: .constant(0), ContentActive: .constant(false))
        .preferredColorScheme(.dark)
}
