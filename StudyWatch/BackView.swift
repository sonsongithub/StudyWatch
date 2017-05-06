//
//  BackView.swift
//  StudyWatch
//
//  Created by sonson on 2017/05/05.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit

class BackView: UIView {
    
    var labels: [UILabel] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        (0..<12).forEach({
            
            let label = UILabel(frame: .zero)
            
            label.text = "\($0+1)"
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.font = UIFont.systemFont(ofSize: 36)
            labels.append(label)
            self.addSubview(labels[$0])
        })
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        layoutLabels()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutLabels()
    }
    
    func layoutLabels() {
        let rect = self.frame
        let centerx = rect.size.width/2
        let centery = rect.size.height/2
        var radius = rect.size.width < rect.size.height ? rect.size.width/2 : rect.size.height/2
        radius -= 2

        (0..<12).forEach({
            let ratio = CGFloat(0.8)
            let theta = 2 * CGFloat.pi / 12 * (CGFloat($0) - 2)
            let x1 = centerx + ratio * radius * cos(theta)
            let y1 = centery + ratio * radius * sin(theta)
            
            let width = CGFloat(100)
            let height = CGFloat(100)
            print(x1 - x1 - width/2)
            labels[$0].frame = CGRect(x: x1 - width/2 , y: y1 - height/2, width: 100, height: 100)
        })
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let centerx = rect.origin.x + rect.size.width/2
        let centery = rect.origin.y + rect.size.height/2
        
        var radius = rect.size.width < rect.size.height ? rect.size.width/2 : rect.size.height/2
        radius -= 2
        
        let center = CGPoint(x: centerx, y: centery)
        
        context.addArc(center: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: false)
        context.drawPath(using: .stroke)
        
        (0..<60).forEach({
            let ratio = CGFloat(0.98)
            let theta = 2 * CGFloat.pi / 60 * CGFloat($0)
            let x1 = centerx + ratio * radius * cos(theta)
            let y1 = centerx + ratio * radius * sin(theta)
            let x2 = centerx + radius * cos(theta)
            let y2 = centerx + radius * sin(theta)
            context.addLines(between: [CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2)])
            context.drawPath(using: .stroke)
        })
        
        (0..<12).forEach({
            let ratio = CGFloat(0.94)
            let theta = 2 * CGFloat.pi / 12 * CGFloat($0)
            let x1 = centerx + ratio * radius * cos(theta)
            let y1 = centerx + ratio * radius * sin(theta)
            let x2 = centerx + radius * cos(theta)
            let y2 = centerx + radius * sin(theta)
            context.addLines(between: [CGPoint(x: x1, y: y1), CGPoint(x: x2, y: y2)])
            context.drawPath(using: .stroke)
        })
    }
}
