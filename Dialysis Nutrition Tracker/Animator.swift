//
//  Animator.swift
//  Dialysis Nutrition Tracker
//
//  Created by Steven Chen on 7/15/16.
//  Copyright © 2016 Steven Chen. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning{
    let duration    = 1.0
    var presenting  = true
    var originFrame = CGRect.zero
    var height = 1.0
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?)-> NSTimeInterval {
        return duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        let servingSizeView = presenting ? toView : transitionContext.viewForKey(UITransitionContextFromViewKey)!
        
        servingSizeView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.6)
        let initialFrame = presenting ? originFrame : servingSizeView.frame
        _ = presenting ? servingSizeView.frame : originFrame
        
        if presenting {
          //  customView.center = CGPoint(x: 0,y: 0)
            
            servingSizeView.center = CGPoint(
                x: CGRectGetMidX(initialFrame),
                y: CGRectGetMidY(initialFrame))
            servingSizeView.clipsToBounds = true
        }
        
        containerView.addSubview(toView)
        containerView.bringSubviewToFront(servingSizeView)
        
        UIView.animateWithDuration(duration, delay:0.0,
                                   options: [],
                                   animations: {
                                    servingSizeView.frame =  CGRectMake(0 , 0, servingSizeView.frame.width, servingSizeView.frame.height)

            }, completion:{_ in
                transitionContext.completeTransition(true)
        })
    }
}
