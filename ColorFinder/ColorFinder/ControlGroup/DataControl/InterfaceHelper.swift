//
//  InterfaceHelper.swift
//  SocialCrop
//
//  Created by Mostafizur Rahman on 4/10/18.
//  Copyright © 2018 image-app. All rights reserved.
//

import UIKit

class InterfaceHelper: NSObject {
    static let IS_PAD = UIDevice.current.userInterfaceIdiom == .pad
    static let MS_HEIGHT = UIScreen.main.bounds.height
    static let MS_WIDTH = UIScreen.main.bounds.width
    static let MS_SIZE = UIScreen.main.bounds.size
    static let MS_BOUND =  UIScreen.main.bounds
    static let MS_HLFH =  UIScreen.main.bounds.height / 2
    static let MS_HLFW =  UIScreen.main.bounds.width / 2
    
    typealias IH = InterfaceHelper
    static let DOC_PATH = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    
    static func set(Safearea layouts:[NSLayoutConstraint]){
        if !IH.hasTopNotch {
            for layout in layouts {
                layout.constant = 0
            }
        }
    }
    static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    static func set(Layouts layouts:[NSLayoutConstraint], ToParent view:UIView? = nil){
        if !IH.hasTopNotch {
            for layout in layouts {
                layout.constant -= 44
            }
        }
        UIView.animate(withDuration: 0.4) {
            view?.layoutIfNeeded()
        }
    }
    
    static func randomStr(_ n: Int) -> String {
        let a = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        var s = ""
        for _ in 0..<n {
            let r = Int(arc4random_uniform(UInt32(a.count)))
            s += String(a[a.index(a.startIndex, offsetBy: r)])
        }
        
        return s
    }
    
    static func animateOpacity(toInvisible animateView:UIView,
                               atDuration duratino:CGFloat,
                               onCompletion completion:@escaping (_ finished: Bool) -> Void) {
    
        if let superview = animateView.superview {
            superview.bringSubviewToFront(animateView)
            animateView.isHidden = false
            animateView.layer.opacity = 1.0
            let transform = animateView.layer.transform
            UIView.animate(withDuration: TimeInterval(duratino), animations: {
                animateView.layer.transform = CATransform3DConcat(transform, CATransform3DMakeScale(0.6, 0.6, 1.0))
                animateView.layer.opacity = 0.0
            }) { (finished) in
                superview.sendSubviewToBack(animateView)
                completion(finished)
                NotificationCenter.default.post(name: NSNotification.Name.init("hide_banner"), object: ["hide_ad":false])
            }
        }
    }
    
    static func animateOpacity(toVisible animateView:UIView,
                               atDuration duratino:CGFloat,
                               onCompletion completion:@escaping (_ finished: Bool) -> Void) {

        if let superview = animateView.superview {
            superview.bringSubviewToFront(animateView)
            animateView.isHidden = false
            animateView.layer.opacity = 0.0
            animateView.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0)
            UIView.animate(withDuration: TimeInterval(duratino), animations: {
                animateView.layer.opacity = 1.0
                animateView.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }) { (finished) in
                completion(finished)
                NotificationCenter.default.post(name: NSNotification.Name.init("hide_banner"), object: ["hide_ad":true])
            }
        }
    }
    
    static public func updateView(inVisibleBound boundingRect:CGRect,
                                  forView sourceView:UIView){
        
        let sourceOrigin = sourceView.frame.origin
        let sourceSize = sourceView.frame.size
        let maskOrigin = boundingRect.origin
        let maskSize = boundingRect.size
        var originX:CGFloat = sourceOrigin.x
        var originY:CGFloat = sourceOrigin.y
        let sumS = sourceOrigin.y + sourceSize.height
        let sumM = maskOrigin.y + maskSize.height
        let sumSX = sourceOrigin.x + sourceSize.width
        let sumMX = maskOrigin.x + maskSize.width
        if sourceOrigin.x > maskOrigin.x {
            originX = maskOrigin.x
            if sourceOrigin.y > maskOrigin.y {
                originY = maskOrigin.y
            } else if sumS < sumM {
                originY += sumM - sumS
            }
        } else if sourceOrigin.y > maskOrigin.y {
            originY = maskOrigin.y
            if sourceOrigin.x > maskOrigin.x {
                originX = maskOrigin.x
            } else if sumSX < sumMX {
                originX += sumMX - sumSX
            }
        } else if sumSX < sumMX {
            originX += sumMX - sumSX
            if sumS < sumM {
                originY += sumM - sumS
            }
        } else if sumS < sumM {
            originY += sumM - sumS
            if sumSX < sumMX {
                originX += sumMX - sumSX
            }
        }
        
        let finalRect = CGRect(origin:CGPoint(x:originX, y:originY), size:sourceSize)
        
        UIView.animate(withDuration: 0.3, animations: {
            sourceView.frame = finalRect
        }) { (finished) in
            
        }
    }

}
extension String {
    subscript(value: NSRange) -> Substring {
        return self[value.lowerBound..<value.upperBound]
    }
}

extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...index(at: value.upperBound)]
        }
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        get {
            return self[..<index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        get {
            return self[...index(at: value.upperBound)]
        }
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        get {
            return self[index(at: value.lowerBound)...]
        }
    }
    
    func index(at offset: Int) -> String.Index {
        return index(startIndex, offsetBy: offset)
    }
}
