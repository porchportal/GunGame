//
//  SplashScreenView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 7/1/2567 BE.
//

import SwiftUI

struct SplashScreenView: View {
    @State var isActive : Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.3
    @Binding var status :Int
    
    var body: some View {
        if isActive {
            ManageView()
        } else {
            ZStack{
                Rectangle()
                    .foregroundStyle(.black)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    VStack {
                        Image("Space01.001")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 2)
                            .shadow(color: .blue, radius: 10, x: 0, y: 0)
                            .shadow(color: .blue, radius: 60, x: 0, y: 0)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 1.2)) {
                            self.size = 1.0
                            self.opacity = 1.00
                        }
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(status: .constant(0))
}
