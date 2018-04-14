//
//  ViewController.swift
//  Generhizo
//
//  Created by Cor Pruijs on 13-04-18.
//  Copyright © 2018 Cor Pruijs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var generhizoButtonPressed: UIButton!
    
    @IBAction func generhizoButtonPressed(_ sender: UIButton) {
        
        
        view.layer.backgroundColor = UIColor.green.cgColor
        
        for x in -5...5 {
            for y in -5...5 {
                view.layer.addSublayer(sublayerConstructor(x: CGFloat(x * 150), y: CGFloat(y * 150)))
            }
        }
    }
    
    private func sublayerConstructor(x: CGFloat, y: CGFloat) -> CALayer {
        let sublayer = CALayer()
        sublayer.backgroundColor = UIColor.red.cgColor
        sublayer.frame = CGRect(x: view.layer.frame.width / 2 - 50 + x, y: view.layer.frame.height / 2 - 50 + y, width: 100, height: 100)
        return sublayer
    }

}

