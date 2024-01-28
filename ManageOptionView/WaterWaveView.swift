//
//  WaterWaveView.swift
//  MathShooter29
//
//  Created by วรัญพงษ์ สุทธิพนไพศาล on 7/1/2567 BE.
//

import SwiftUI

class WaterWaveView: UIView{
    
    private let firstLayer = CAShapeLayer()
    private let secondLayer = CAShapeLayer()
    
    private let percetLbl = UILabel()
    
    private var firstColor: UIColor = .clear
    private var secondColor: UIColor = .clear
    
    private var twoPi: CGFloat = .pi*2
    private var offset: CGFloat = 0.0
    
    private let width = screenWidth * 0.5
    
    var showSingleWave = false
    private var start = false
    
    var progress: CGFloat = 0.0
    var waveHeight: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
}
extension WaterWaveView{
    private func setupView(){
        bounds = CGRect(x: 0.0, y: 0.0, width: min(width, width), height: min(width, width))
        clipsToBounds = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = width/2
        layer.masksToBounds = true
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.lightGray.cgColor
        
        waveHeight = 8.0
        firstColor = .cyan
        secondColor = .cyan.withAlphaComponent(0.4)
        
        createFirstLayer()
        
        if !showSingleWave{
            createSecondLayer()
        }
        createPercentLbl()
    }
    private func createFirstLayer(){
        firstLayer.frame = bounds
        firstLayer.anchorPoint = .zero
        firstLayer.fillColor = firstColor.cgColor
        layer.addSublayer(firstLayer)
    }
    private func createSecondLayer(){
        secondLayer.frame = bounds
        secondLayer.anchorPoint = .zero
        secondLayer.fillColor = secondColor.cgColor
        layer.addSublayer(secondLayer)
    }
    private func createPercentLbl(){
        percetLbl.font = UIFont.boldSystemFont(ofSize: 35)
        percetLbl.textAlignment = .center
        percetLbl.text = ""
        percetLbl.textColor = .darkGray
        addSubview(percetLbl)
        percetLbl.translatesAutoresizingMaskIntoConstraints = false
        percetLbl.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        percetLbl.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    func percentAnim(){
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.duration = 1.5
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        
        percetLbl.layer.add(anim, forKey: nil)
    }
    func setupProgress(_ pr: CGFloat){
        progress = pr
        //percetLbl.text = String(format: "%ld%%", NSNumber(value: Int(Float(pr*100))))
        percetLbl.text = String(format: "%.0f%%", pr * 100)
        //let top: CGFloat = 1 * bounds.size.height/2
        let top: CGFloat = pr * bounds.size.height
        firstLayer.setValue(width-top, forKeyPath: "position.y")
        secondLayer.setValue(width-top, forKeyPath: "position.y")
        
        if !start {
            DispatchQueue.main.async {
                self.startAnim()
            }
        }
    }
    private func startAnim(){
        start = true
        waterWaveAnim()
    }
    private func waterWaveAnim(){
        let w = bounds.size.width
        let h = bounds.size.height
        
        let bezier = UIBezierPath()
        let path = CGMutablePath()
        
        let startOffsetY = waveHeight * CGFloat(sinf(Float(offset * twoPi / w)))
        var originOffsetY: CGFloat = 0.0
        
        path.move(to: CGPoint(x: 0.0, y: startOffsetY), transform: .identity)
        bezier.move(to: CGPoint(x: 0.0, y: startOffsetY))
        
        for i in stride(from: 0.0, to: w*1000, by: 1){
            originOffsetY = waveHeight * CGFloat(sinf(Float(twoPi / w * i + offset * twoPi / w)))
            bezier.addLine(to: CGPoint(x: i, y: originOffsetY))
        }
        bezier.addLine(to: CGPoint(x: w*100, y: originOffsetY))
        bezier.addLine(to: CGPoint(x: w*100, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: h))
        bezier.addLine(to: CGPoint(x: 0.0, y: startOffsetY))
        bezier.close()
        
        let anim = CABasicAnimation(keyPath: "transform.translation.x")
        anim.duration = 2.0
        anim.fromValue = -w*0.5
        anim.toValue = -w - w*0.5
        anim.repeatCount = .infinity
        anim.isRemovedOnCompletion = false
        
        firstLayer.fillColor = firstColor.cgColor
        firstLayer.path = bezier.cgPath
        firstLayer.add(anim, forKey: nil)
        
        if !showSingleWave {
            let bezier = UIBezierPath()
            
            let startOffsetY = waveHeight * CGFloat (sinf(Float(offset * twoPi / w) ))
            var originOffsetY: CGFloat = 0.0
            bezier.move(to: CGPoint(x: 0.0, y: startOffsetY))
            
            for i in stride(from: 0.0, to: w * 1000, by: 1){
                originOffsetY = waveHeight * CGFloat(cosf(Float(twoPi / w * i + offset * twoPi / w)))
                bezier.addLine(to: CGPoint(x: i, y: originOffsetY))
            }
            bezier.addLine(to: CGPoint(x: w*100, y: originOffsetY))
            bezier.addLine(to: CGPoint(x: w*100, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: h))
            bezier.addLine(to: CGPoint(x: 0.0, y: startOffsetY))
            bezier.close()
            
            let anim = CABasicAnimation(keyPath: "tranform.translation.x")
            anim.duration = 2.0
            anim.fromValue = -w * 0.5
            anim.toValue = -w - w*0.5
            anim.repeatCount = .infinity
            anim.isRemovedOnCompletion = false
            
            secondLayer.fillColor = secondColor.cgColor
            secondLayer.path = bezier.cgPath
            secondLayer.add(anim, forKey: nil)
        }
    }
}
#Preview {
    ViewControl()
}
