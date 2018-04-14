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
        baseSublayer = sublayerConstructor(x: view.layer.frame.width / 2 - 50, y: view.layer.frame.height / 2 - 50)
        
        for x in -5...5 {
            for y in -5...5 {
                baseSublayer!.addSublayer(sublayerConstructor(x: CGFloat(x * 150), y: CGFloat(y * 150)))
            }
        }
        view.layer.addSublayer(baseSublayer!)
    }
    
    
    @IBAction func generhizoButtonPressed(_ sender: UIButton) {
        
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi
        animation.duration = 2
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        baseSublayer!.add(animation, forKey: "rotate")
    }
    
    private func sublayerConstructor(x: CGFloat, y: CGFloat) -> CALayer {
        let sublayer = CALayer()
        sublayer.backgroundColor = UIColor.black.cgColor
        sublayer.frame = CGRect(x: x, y: y, width: 100, height: 100)
        return sublayer
    }

}

