//
//  StoriesScreenAnimatorPresent.swift
//  StoriesNavigations
//
//  Created by Semyon on 27.11.2020.
//

import UIKit

class StoriesScreenAnimatorPresent: NSObject, UIViewControllerAnimatedTransitioning {
    
    private enum Spec {
        static let animationDuration: TimeInterval = 0.3
    }
    
    private let startFrame: CGRect

    init(startFrame: CGRect) {
        self.startFrame = startFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Spec.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 1
        guard let vcTo = transitionContext.viewController(forKey: .to),
              let snapshot = vcTo.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }

        // 2
        let containerView = transitionContext.containerView
        
        // 3
        containerView.addSubview(vcTo.view)
        vcTo.view.isHidden = true

        // 4
        snapshot.frame = startFrame
        snapshot.alpha = 0.0
        
        containerView.addSubview(snapshot)

        UIView.animate(withDuration: Spec.animationDuration, animations: {
            // 5
            snapshot.frame = (transitionContext.finalFrame(for: vcTo))
            snapshot.alpha = 1.0
        }, completion: { _ in
            // 6
            vcTo.view.isHidden = false
            snapshot.removeFromSuperview()
            
            // 7
            if transitionContext.transitionWasCancelled {
                vcTo.view.removeFromSuperview()
            }
            
            // 8
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

