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
    
    var baseDepth = 3
    
    // mode
    var growMode = false
    var motionMode = true
    var eightTwigMode = true
    var naturalMode = true
    var centerLeftMode = true
    var endLeftMode = true
    var endRightMode = true
    var darkMode = false
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var depthLabel: UILabel!
    @IBOutlet weak var stepperValue: UIStepper!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var shrinkSlider: UISlider!
    
    // hide statusbar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // motion
    let motionManager = CMMotionManager()
    var timer: Timer?
    
    var xRotation = 1.0
    var yRotation = 1.0
    var zRotation = 1.0
    
    var startZRotation: Double? = nil {
        didSet {
            print(startZRotation)
        }
    }
    
    @IBAction func tapRecognized(_ sender: UITapGestureRecognizer) {
        // toggle the controlsview on a double tap
        controlsView.isHidden = !controlsView.isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        render()
        startDeviceMotion()
        
        depthLabel.text = "\(baseDepth)"
        
        stepperValue.minimumValue = 1
        stepperValue.maximumValue = 5
        stepperValue.value = Double(baseDepth)
        
        controlsView?.isHidden = true
        
       
    }
    
    private func startDeviceMotion() {
        motionManager.deviceMotionUpdateInterval = 1.0 / 60
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
        
        self.timer = Timer(fire: Date(), interval: (1.0/60.0), repeats: true) { (timer) in
            if let data = self.motionManager.deviceMotion {
               
                if (self.motionMode) {
                    // Get the attitude relative to the magnetic north reference frame.
                    let x = data.attitude.pitch
                    let y = data.attitude.roll
                    let z = data.attitude.yaw
                    
                    
                    if self.startZRotation == nil {
                        self.startZRotation = z
                        print("setting start rotation")
                    }
                    
                    self.xRotation = x
                    self.yRotation = y
                    self.zRotation = z
              
                    self.render()
                }
                
            }
        }
        
        RunLoop.current.add(self.timer!, forMode: .defaultRunLoopMode)
    }
    
    
    private func render() {

        view.layer.backgroundColor = darkMode ? UIColor.black.cgColor : UIColor.white.cgColor
        
        // Init baselayer
        if let baseSublayer = baseLayer {
            baseSublayer.removeFromSuperlayer()
        }
        baseLayer = sublayerConstructor(x: view.layer.frame.width / 2 - 5, y: view.layer.frame.height / 2 - 5)

        
        // Add tree structure
        func addLine(from: CGPoint, depth: Int, direction: Int, left: Bool) -> CALayer {
            
            
            // Rollover direction
            var dir = depth == baseDepth ? direction : direction + (left ? 1 : -1)
            
            if dir == -1 {
                dir = 7
            } else if dir == 8 {
                dir = 0
            }
            
            
            
            let end: CGPoint
            let length: CGFloat
            if let startZRot = startZRotation {
                
                //print("zStart: \(startZRot), zCalc: \(fabs(CGFloat(zRotation) - fabs(CGFloat(startZRot))))")
//                length = (dir % 2 == 0 ? 100 * CGFloat(yRotation) : 100 * CGFloat(xRotation)) * (CGFloat(depth) / CGFloat(baseDepth))
                
                let zValue = fabs(CGFloat(zRotation))
                self.zLabel.text = "\(Double(round(1000*zValue)/1000))"
                length = (dir % 2 == 0 ? 100 * CGFloat(yRotation) : -75 * zValue) * max((CGFloat(depth) /  (CGFloat(baseDepth))), CGFloat(shrinkSlider!.value))
            } else {
                length = (dir % 2 == 0 ? 150 : 100) * (CGFloat(depth) / CGFloat(baseDepth))
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
                let timeDelay = (Double(baseDepth - depth) * growDuration)
                
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
                if centerLeftMode {
                  layer.addSublayer(addLine(from: center, depth: depth - 1, direction: direction, left: left))
                }
                
                if naturalMode {
                    layer.addSublayer(addLine(from: center, depth: depth - 1, direction: direction, left: !left))
                }
                
                if endLeftMode {
                    layer.addSublayer(addLine(from: end, depth: depth - 1, direction: direction, left: left))
                }
                
                if endRightMode {
                    layer.addSublayer(addLine(from: end, depth: depth - 1, direction: direction, left: !left))
                }
                
            }
            
            return layer
        }
        
        
        for direction in 0...7 {
            if direction % 2 == 0 || eightTwigMode {
                baseLayer?.addSublayer(addLine(from: CGPoint(x: 5, y: 5), depth: baseDepth, direction: direction, left: true))
            }
            
        }
        view.layer.addSublayer(baseLayer!)
    }
    
    
    
    private func sublayerConstructor(x: CGFloat, y: CGFloat) -> CALayer {
        let sublayer = CALayer()
        sublayer.backgroundColor = darkMode ? UIColor.white.cgColor : UIColor.black.cgColor
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
        lineLayer.strokeColor = darkMode ? UIColor.white.cgColor : UIColor.black.cgColor
        lineLayer.lineWidth = width
        
        let center = CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2)
        return (layer: lineLayer, center: center)
    }

    @IBAction func motionSwitchUpdated(_ sender: UISwitch) {
        motionMode = sender.isOn
        growMode = !motionMode
        
        if !motionMode {
            xRotation = 1.0
            yRotation = 1.0
            zRotation = 1.0
            startZRotation = nil
        }
        render()
    }
    @IBAction func naturalSwitchUpdated(_ sender: UISwitch) {
        naturalMode = sender.isOn
        render()
    }
    @IBAction func darkModeSwitchUpdated(_ sender: UISwitch) {
        darkMode = sender.isOn
        render()
    }
    
    @IBAction func centerLeftSwitchUpdated(_ sender: UISwitch) {
        centerLeftMode = sender.isOn
        render()
    }
    
    @IBAction func endLeftSwitchUpdated(_ sender: UISwitch) {
        endLeftMode = sender.isOn
        render()
    }
    
    @IBAction func endRightSwitchUpdated(_ sender: UISwitch) {
        endRightMode = sender.isOn
        render()
    }
    
    @IBAction func twigCountSwitchUpdated(_ sender: UISwitch) {
        eightTwigMode = sender.isOn
        render()
    }
    
    @IBAction func depthStepperUpdated(_ sender: UIStepper) {
        let stepValue = Int(stepperValue.value)
        depthLabel.text = "\(Int(stepperValue.value))"
        baseDepth = stepValue
    }
    
}

