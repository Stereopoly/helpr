//
//  danthingy.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 7/8/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit

extension UIView {
    
    func getBorderTag() -> Int {
        return 70 // can be any number
    }
    
    func removeBorder() {
        self.viewWithTag(self.getBorderTag())?.removeFromSuperview()
    }
    
    func addBorderToBottomWithThickness(thickness: Int, color: UIColor) {
        let border = UIView()
        
        border.backgroundColor = color
        border.tag = self.getBorderTag()
        
        border.frame = CGRectMake(0, self.frame.size.height - CGFloat(thickness), self.frame.size.width, CGFloat(thickness))
        
        self.addSubview(border)
    }
}
