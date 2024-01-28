//
//  Testing01.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 8/1/2567 BE.
//

import SwiftUI
import UIKit
import Photos

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPicker

        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }

            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

struct Testing01: View {
    @State private var selectedImage: UIImage?
    @State private var showPhotoPicker = false
    @Binding var showTemporaryView : Bool
    @State private var gameScene : Game_Scene? = nil
    let chosenPlayer = 1
    var body: some View {
        VStack {
            ViewControlShow()
                .frame(height: 300)
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            Button("Pick Photo") {
                showPhotoPicker = true
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(image: $selectedImage)
                //showTemporaryView = false
            }
            
        }
    }
}

#Preview {
    Testing01(showTemporaryView: .constant(false))
}
