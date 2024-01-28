//
//  MathShooter29App.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 19/12/2566 BE.
//

import SwiftUI

@main
struct MathShooter29App: App {
    var body: some Scene {
        WindowGroup {
            //SupportG()
            //IceShared()
            //Testing01()
            //ManageView()
            //MusicManager(status: .constant(0))
            //TestingView3()
            SplashScreenView(status: .constant(0)) //main
                .preferredColorScheme(.dark)
        }
    }
}
