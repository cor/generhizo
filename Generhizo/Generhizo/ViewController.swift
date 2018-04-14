//
//  ViewController.swift
//  Generhizo
//
//  Created by Cor Pruijs on 13-04-18.
//  Copyright © 2018 Cor Pruijs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var baseSublayer: CALayer?
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        addSublayers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addSublayers()
    }
    
    private func addSublayers() {

        if let baseSublayer = baseSublayer {
            baseSublayer.removeFromSuperlayer()
        }
        
        baseSublayer = sublayerConstructor(x: view.layer.frame.width / 2 - 5, y: view.layer.frame.height / 2 - 5)

        
        let (lineLayer, lineCenter) = lineLayerConstructor(start: CGPoint(x: 5, y: 5), end: CGPoint(x: 100, y: 100), width: 2)
        let (lineLayer2, lineCenter2) = lineLayerConstructor(start: lineCenter, end: CGPoint(x: lineCenter.x - 100, y: lineCenter.y + 100), width: 2)
        let (lineLayer3, lineCenter3) = lineLayerConstructor(start: lineCenter2, end: CGPoint(x: lineCenter2.x + 100, y: lineCenter2.y + 100), width: 2)
        
        baseSublayer?.addSublayer(lineLayer)
        lineLayer.addSublayer(lineLayer2)
        lineLayer2.addSublayer(lineLayer3)
        
        
        
        baseSublayer?.addSublayer(lineLayerConstructor(start: CGPoint(x: 5, y: 5), end: CGPoint(x: -100, y: -100), width: 2).layer)

        
//        let squareCount = 25
        
//        for x in -squareCount...squareCount {
//            for y in -squareCount...squareCount {
//                baseSublayer!.addSublayer(sublayerConstructor(x: CGFloat(x * 15), y: CGFloat(y * 15)))
//            }
//        }
        view.layer.addSublayer(baseSublayer!)
    }
    
    
    @IBAction func generhizoButtonPressed(_ sender: UIButton) {
        
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        baseSublayer!.add(animation, forKey: "rotate")
    }
    
    private func sublayerConstructor(x: CGFloat, y: CGFloat) -> CALayer {
        let sublayer = CALayer()
        sublayer.backgroundColor = UIColor.black.cgColor
        sublayer.frame = CGRect(x: x, y: y, width: 10, height: 10)
        return sublayer
    }
    
    private func lineLayerConstructor(start: CGPoint, end: CGPoint, width: CGFloat) -> (layer: CALayer, center: CGPoint) {
        let lineLayer = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = nil
        lineLayer.strokeColor = UIColor.black.cgColor
        lineLayer.lineWidth = width
        
        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        return (layer: lineLayer, center: center)
    }

}

