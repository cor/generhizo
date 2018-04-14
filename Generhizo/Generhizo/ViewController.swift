//
//  ViewController.swift
//  Generhizo
//
//  Created by Cor Pruijs on 13-04-18.
//  Copyright © 2018 Cor Pruijs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var baseLayer: CALayer?
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        addSublayers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        addSublayers()
    }
    
    private func addSublayers() {

        // Init baselayer
        if let baseSublayer = baseLayer {
            baseSublayer.removeFromSuperlayer()
        }
        baseLayer = sublayerConstructor(x: view.layer.frame.width / 2 - 5, y: view.layer.frame.height / 2 - 5)

        
        // Add tree structure
        func addLine(from: CGPoint, depth: Int) -> CALayer {

            // base layer
            let (layer, center) = lineLayerConstructor(start: from,
                                                       end: CGPoint(x: from.x + 100 * (depth % 2 == 0 ? 1 : -1), y: from.y + 100),
                                                       width: 2)
            
            // Recursively add sublayers
            if (depth <= 0) { // Base case
                return layer
            } else { // Recursive case
                layer.addSublayer(addLine(from: center, depth: depth - 1))
            }
            
            return layer
        }
        
        baseLayer?.addSublayer(addLine(from: CGPoint(x: 5, y: 5), depth: 6))
        
        view.layer.addSublayer(baseLayer!)
    }
    
    
    @IBAction func generhizoButtonPressed(_ sender: UIButton) {
        
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        baseLayer!.add(animation, forKey: "rotate")
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

