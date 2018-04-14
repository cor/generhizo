//
//  ViewController.swift
//  Generhizo
//
//  Created by Cor Pruijs on 13-04-18.
//  Copyright © 2018 Cor Pruijs. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    var baseLayer: CALayer?
    var growMode = false
    var motionMode = true
    
    //motion
    let motionManager = CMMotionManager()
    var timer: Timer?
    
    var xRotation = 1.0
    var yRotation = 1.0
    var zRotation = 1.0
    
    var startZRotation: Double? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSublayers()
        startDeviceMotion()
    }
    
    private func startDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 10
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        
        self.timer = Timer(fire: Date(), interval: (1.0/30.0), repeats: true) { (timer) in
            if let data = self.motionManager.deviceMotion {
               
                if (self.motionMode) {
                    // Get the attitude relative to the magnetic north reference frame.
                    let x = data.attitude.pitch
                    let y = data.attitude.roll
                    let z = data.attitude.yaw
                    
                    print("x: \(x), y: \(y), z: \(z)")
                    
                    if self.startZRotation == nil {
                        self.startZRotation = z
                    }
                    
                    self.xRotation = x
                    self.yRotation = y
                    self.zRotation = z
              
                    self.addSublayers()
                }
                
            }
        }
        
        RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
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
        func addLine(from: CGPoint, depth: Int, direction: Int, left: Bool) -> CALayer {
            
            
            // Rollover direction
            var dir = depth == 6 ? direction : direction + (left ? 1 : -1)
            
            if dir == -1 {
                dir = 7
            } else if dir == 8 {
                dir = 0
            }
            
            
            let end: CGPoint
            let length: CGFloat
            if let startZRot = startZRotation {
                length = (dir % 2 == 0 ? 150 * CGFloat(yRotation) : 100 * CGFloat(zRotation - startZRot)) * (CGFloat(depth) / 6)
            } else {
                length = (dir % 2 == 0 ? 150 : 100) * (CGFloat(depth) / 6)
            }
            // base layer
            switch dir {
            case 0: end = CGPoint(x: from.x,          y: from.y - length)
            case 1: end = CGPoint(x: from.x + length, y: from.y - length)
            case 2: end = CGPoint(x: from.x + length, y: from.y)
            case 3: end = CGPoint(x: from.x + length, y: from.y + length)
            case 4: end = CGPoint(x: from.x,          y: from.y + length)
            case 5: end = CGPoint(x: from.x - length, y: from.y + length)
            case 6: end = CGPoint(x: from.x - length, y: from.y)
            case 7: end = CGPoint(x: from.x - length, y: from.y - length)
            default: end = CGPoint(x: from.x,         y: from.y - length) // same as 0
            }
            
            let (layer, center) = lineLayerConstructor(start: from, end: end, width: 2)
            
            
            if growMode {
                // MARK: - Animation
                let growDuration: Double = 3
                let timeDelay = (Double(6 - depth) * growDuration)
                
                let lineAnimation = CABasicAnimation(keyPath: "strokeEnd")
                lineAnimation.duration = growDuration
                lineAnimation.fromValue = 0
                lineAnimation.toValue = 1
                lineAnimation.beginTime = CACurrentMediaTime() + timeDelay
                lineAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                
                // HACK
                lineAnimation.fillMode = kCAFillModeForwards
                lineAnimation.isRemovedOnCompletion = false
                
                layer.strokeEnd = 0
                
                
                layer.add(lineAnimation, forKey: "strokeEnd")
            }
            
            
            // Recursively add sublayers
            if (depth <= 0) { // Base case
                return layer
            } else { // Recursive case
                layer.addSublayer(addLine(from: center, depth: depth - 1, direction: direction, left: left))
                layer.addSublayer(addLine(from: center, depth: depth - 1, direction: direction, left: !left))
                layer.addSublayer(addLine(from: end, depth: depth - 1, direction: direction, left: !left))
            }
            
            return layer
        }
        
        
        for direction in 0...7 {
//            if direction % 2 == 0 {
                baseLayer?.addSublayer(addLine(from: CGPoint(x: 5, y: 5), depth: 6, direction: direction, left: true))
//            }
            
        }
        view.layer.addSublayer(baseLayer!)
    }
    
    
    
    private func sublayerConstructor(x: CGFloat, y: CGFloat) -> CALayer {
        let sublayer = CALayer()
        sublayer.backgroundColor = UIColor.black.cgColor
        sublayer.frame = CGRect(x: x, y: y, width: 10, height: 10)
        return sublayer
    }
    
    private func lineLayerConstructor(start: CGPoint, end: CGPoint, width: CGFloat) -> (layer: CAShapeLayer, center: CGPoint) {
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

    @IBAction func motionSwitchUpdated(_ sender: UISwitch) {
        motionMode = sender.isOn
        growMode = !sender.isOn
        
        if !motionMode {
            xRotation = 1.0
            yRotation = 1.0
            zRotation = 1.0
            startZRotation = nil
        }
        addSublayers()
    }
    
}

