//
//  RoundButton.swift
//  calc
//
//  Created by Joel Pedraza on 5/4/18.
//  Copyright © 2018 Joel Pedraza. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        recalculateRadius()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        recalculateRadius()
    }
    
    private func recalculateRadius() {
        layer.cornerRadius = frame.height / 2
    }
    
}

@IBDesignable
class CalcButton: RoundButton, CharacterValue {
    
    @IBInspectable
    var charVal: NSString = "0"
    
    var charValue: Character {
        return Character(charVal as String)
    }
    
    
    
}

