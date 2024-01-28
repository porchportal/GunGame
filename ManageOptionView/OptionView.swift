//
//  OptionView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 7/1/2567 BE.
//

import SwiftUI

struct ViewControlShow: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewControl {
        return ViewControl()
    }

    func updateUIViewController(_ uiViewController: ViewControl, context: Context) {
        // Update the view controller if needed
    }
}
struct OptionView: View {
    @Binding var showTemporaryView : Bool
    @Binding var status: Int
    @State private var selectedImage: UIImage?
    @ObservedObject var scene = Game_Scene(size: .zero)
    @State private var avatarImage: UIImage?
    @State private var showAlert = false
    @State private var changfeView = false
    
    var body: some View {
        VStack{
            Button("Testing"){
                changfeView = true
            }
            .font(.custom("leading", size: 50))
            .padding(20)
            //.position(CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/1.5))
            ZStack{
                //ViewControlShow()
                 //   .frame(height: 200)
                //PickPhotos(avaterImage: $avatarImage)
            }
            .frame(width: 100, height: 100)
            /*Button("Save") {
                if let newImage = avatarImage {
                    //scene.updateBossOneImage(with: newImage)
                    saveImageToLocal(image: newImage, imageName: "bossOneImage")
                    showAlert = true
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Saved"), message: Text("Your image has been saved."), dismissButton: .default(Text("OK")))
            }*/
            
            Button{
                status = 6
            } label: {
                Text("Manage Music")
                    .font(.custom("leading", size: 50))
            }
            Button{
                status = 1
            } label: {
                Text("back to start")
            }
        }
        .sheet(isPresented: $changfeView, content: {
            TestingView3()
        })
        .onAppear{
            self.avatarImage = loadImageFromLocal(imageName: "bossOneImage")
        }
    }
    func saveImageToLocal(image: UIImage, imageName: String) {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as URL else {
            return
        }
        do {
            try data.write(to: directory.appendingPathComponent("\(imageName).png"))
        } catch {
            print(error.localizedDescription)
        }
    }

    func loadImageFromLocal(imageName: String) -> UIImage? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as URL else {
            return nil
        }
        let url = directory.appendingPathComponent("\(imageName).png")
        if let imageData = try? Data(contentsOf: url) {
            return UIImage(data: imageData)
        }
        return nil
    }
}

#Preview {
    OptionView(showTemporaryView: .constant(false), status: .constant(0))
}
