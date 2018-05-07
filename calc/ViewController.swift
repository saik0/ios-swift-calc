//
//  ViewController.swift
//  calc
//
//  Created by Joel Pedraza on 5/5/18.
//  Copyright © 2018 Joel Pedraza. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calcValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func calcPressed(_ sender: UIButton) {
        if 0...9 ~= sender.tag {
            calcValue.text = (calcValue.text ?? "") + String(sender.tag)
        }
    }
}

