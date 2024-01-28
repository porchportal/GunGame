//
//  TestingView3.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 25/1/2567 BE.
//

import SwiftUI
import PhotosUI

var BossChoice = UserDefaults.standard
@MainActor
final class PhotoPickerViewModel: ObservableObject{
    @Published private(set) var seledtedImage: UIImage? = nil
    @Published var imageSelection: PhotosPickerItem? = nil{
        didSet{
            setImage(from: imageSelection)
        }
    }
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        Task{
            if let data = try? await selection.loadTransferable(type: Data.self){
                if var uiImage = UIImage(data: data){
                    let targetSize = CGSize(width: 50, height: 50) // Specify your desired size
                    uiImage = customizeImage(uiImage, toSize: targetSize)
                    DispatchQueue.main.async {
                        self.seledtedImage = uiImage
                        self.saveImageToFileSystem(uiImage)
                    }
                }
            }
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                seledtedImage = uiImage
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    private func saveImageToFileSystem(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.5) {
            let filename = getDocumentsDirectory().appendingPathComponent("BossImage.jpg")
            do {
                try data.write(to: filename)
                BossChoice.set(filename.path, forKey: "BossImagePath")
            } catch {
                print("Error saving image to file system: \(error)")
            }
        }
    }
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    private func customizeImage(_ image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
var BossChoice2 = UserDefaults.standard
@MainActor
final class PhotoPickerViewModel2: ObservableObject{
    @Published private(set) var seledtedImage2: UIImage? = nil
    @Published var imageSelection2: PhotosPickerItem? = nil{
        didSet{
            setImage(from: imageSelection2)
        }
    }
    private func setImage(from selection: PhotosPickerItem?){
        guard let selection else {return}
        Task{
            if let data = try? await selection.loadTransferable(type: Data.self){
                if let uiImage = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.seledtedImage2 = uiImage
                        // Save the image to the file system and store the path in UserDefaults
                        self.saveImageToFileSystem(uiImage)
                    }
                }
            }
            do {
                let data = try await selection.loadTransferable(type: Data.self)
                guard let data, let uiImage = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                seledtedImage2 = uiImage
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    private func saveImageToFileSystem(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let filename = getDocumentsDirectory().appendingPathComponent("BossImage.jpg")
            do {
                try data.write(to: filename)
                BossChoice2.set(filename.path, forKey: "BossImage2Path")
            } catch {
                print("Error saving image to file system: \(error)")
            }
        }
    }
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
struct TestingView3: View {
    @StateObject private var viewModel = PhotoPickerViewModel()
    @StateObject private var viewModel2 = PhotoPickerViewModel2()
    
    @State private var navigateToOthers = false
    //@State private var navigateToOthers2 = false
    var body: some View {
        NavigationView{
            VStack(spacing: 40){
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                
                Button{
                    //others()
                    navigateToOthers = true
                } label: {
                    Text("go to the game stimulation")
                }
                .background(
                    NavigationLink(destination: others(), isActive: $navigateToOthers){
                        EmptyView()
                    }
                        .hidden()
                )
                HStack{
                    if let image = viewModel.seledtedImage{
                        Image(uiImage:image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                    }
                    if let image2 = viewModel2.seledtedImage2{
                        Image(uiImage:image2)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 200, height: 200)
                            .cornerRadius(10)
                    }
                }
                PhotosPicker(selection: $viewModel.imageSelection, matching: .images){
                    Text("Open the photo picker!")
                        .foregroundColor(.red)
                }
                /*PhotosPicker(selection: $viewModel2.imageSelection2, matching: .images){
                    Text("another phtos")
                        .foregroundColor(.blue)
                }*/
            }
        }
    }
}

#Preview {
    TestingView3()
}

