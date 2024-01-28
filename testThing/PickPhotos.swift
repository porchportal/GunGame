//
//  PickPhotos.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 10/1/2567 BE.
//

import SwiftUI
import PhotosUI

struct PickPhotos: View {
    @Binding var avaterImage: UIImage?
    @State private var photosPickItem: PhotosPickerItem?
    
    var body: some View {
        VStack{
            PhotosPicker(selection: $photosPickItem, matching: .images){
                Image(uiImage: avaterImage ?? UIImage(imageLiteralResourceName: "DefaultShip"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipShape(.circle)
            }
        }
        .onChange(of: photosPickItem){ _, _ in
            Task{
                if let photosPickItem, let data = try? await photosPickItem.loadTransferable(type: Data.self){
                    if let image = UIImage(data: data){
                        avaterImage = image
                    }
                }
                photosPickItem = nil
            }
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
    PickPhotos(avaterImage: .constant(nil))
}
