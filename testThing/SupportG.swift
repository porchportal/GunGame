//
//  SupportG.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 24/12/2566 BE.
//

import SwiftUI
import SpriteKit

class Game_Testing_Scene: SKScene, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var maskingCamerRollChoice: Bool = false
    var maskOffSet : CGPoint = CGPoint.zero
    override func didMove(to view: SKView) {

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for touch in touches {
            //let location = touch.location(in: self)
            getPhotoFromSource(source: UIImagePickerController.SourceType.camera)
        //}
    }
    //override func update(_ currentTime: TimeInterval) {
    //}
}

extension Game_Testing_Scene{
    func getPhotoFromSource(source: UIImagePickerController.SourceType){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.modalPresentationStyle = .currentContext
            imagePicker.delegate = self
            imagePicker.sourceType = source
            imagePicker.allowsEditing = false
            
            if let viewController = self.view?.window?.rootViewController {
                viewController.present(imagePicker, animated: true, completion: nil)
            }
        } else {
            print("what device are you using")
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if (picker.sourceType == UIImagePickerController.SourceType.photoLibrary || picker.sourceType == UIImagePickerController.SourceType.camera){
            
        }
        picker.dismiss(animated: true, completion: nil)
        picker.delegate = nil
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        picker.delegate = nil
    }
}
struct SupportG: View {
    var scene = Game_Testing_Scene()
    var body: some View {
        ZStack{
            SpriteView(scene: scene)
        }
    }
}
#Preview {
    SupportG()
}
