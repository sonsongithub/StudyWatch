//
//  LongHandView.swift
//  StudyWatch
//
//  Created by sonson on 2017/05/05.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

class LongHandView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        let centerx = rect.origin.x + rect.size.width/2
        let centery = rect.origin.y + rect.size.height/2
        
        let edgex = centerx
        let egedy = rect.origin.y + rect.size.height * 0.05
        
        print(centery)
        print(egedy)
        
        context.setLineWidth(4)
        context.addLines(between: [CGPoint(x: centerx, y: centery), CGPoint(x: edgex, y: egedy)])
        context.drawPath(using: .stroke)
        
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        setNeedsDisplay()
    }
}
