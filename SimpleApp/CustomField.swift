//
//  CustomField.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 7/8/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit

class customField: UITextField {
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        self.layer.backgroundColor = UIColor(red: 44/250, green: 62/250, blue: 80/250, alpha: 1.0).CGColor
        
    }
    
}
