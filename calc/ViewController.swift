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
    
    private var clearOnAppend = false
    
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
        let newText: String
        
        if (clearOnAppend) {
            newText = text
            clearOnAppend = false
        } else {
            newText = (calcValue.text ?? "") + text
        }
        
        calcValue.text = newText
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        calcValue.text = ""
    }
    
    @IBAction func numPressed(_ sender: UIButton) {
        append(text: String(sender.tag))
    }
    
    @IBAction func calcPressed(_ sender: CalcButton) {
        append(text: sender.stringValue)
    }
    
    @IBAction func equalPressed(_ sender: UIButton) {
        do {
            let tokens = try scan(text: (calcValue.text ?? ""))
            let ast = try parse(tokens: tokens)
            
            let result = eval(expr: ast)
            calcValue.text = result.format
        } catch {
            calcValue.text = "E"
            clearOnAppend = true
        }
    }
}

