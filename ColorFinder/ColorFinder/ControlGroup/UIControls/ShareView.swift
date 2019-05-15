//
//  ShareView.swift
//  SocialCrop
//
//  Created by Mostafizur Rahman on 11/10/18.
//  Copyright © 2018 image-app. All rights reserved.
//

import UIKit

class ShareView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.setFillColor(UIColor.white.withAlphaComponent(0.4).cgColor)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x:0, y:55))
        bezierPath.addCurve(to: CGPoint(x:15, y:40) ,
                            controlPoint1: CGPoint(x:0, y:40),
                            controlPoint2: CGPoint(x:0, y:40))

        bezierPath.addArc(withCenter: CGPoint(x:rect.size.width / 2, y:40),
                          radius: 40, startAngle: CGFloat(-Double.pi),
                          endAngle: 0, clockwise: true)
        bezierPath.addLine(to: CGPoint(x: rect.size.width - 15 , y:40))
        bezierPath.addCurve(to: CGPoint(x:rect.size.width, y:55),
                            controlPoint1: CGPoint(x:rect.size.width, y:40),
                            controlPoint2: CGPoint(x:rect.size.width, y:40))
        
        bezierPath.addLine(to: CGPoint(x: rect.size.width , y:rect.size.height - 15))
        bezierPath.addCurve(to: CGPoint(x:rect.size.width - 15, y:rect.size.height),
                            controlPoint1: CGPoint(x:rect.size.width, y: rect.size.height),
                            controlPoint2: CGPoint(x:rect.size.width, y:rect.size.height))
        bezierPath.addLine(to: CGPoint(x: 15 , y:rect.size.height))
        bezierPath.addCurve(to: CGPoint(x:0, y:rect.size.height - 15),
                            controlPoint1: CGPoint(x:0, y:rect.size.height),
                            controlPoint2: CGPoint(x:0, y:rect.size.height))
        bezierPath.addLine(to: CGPoint(x: 0 , y:55))
        bezierPath.fill()
    }

}
