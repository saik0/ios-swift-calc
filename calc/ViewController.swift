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
    
    private func append(text: String) {
        calcValue.text = (calcValue.text ?? "") + text
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        calcValue.text = ""
    }
    
    @IBAction func numPressed(_ sender: UIButton) {
        append(text: String(sender.tag))
    }
    
    @IBAction func calcPressed(_ sender: CalcButton) {
        append(text: String(sender.charVal))
    }
    
    @IBAction func equalPressed(_ sender: UIButton) {
    }
}

