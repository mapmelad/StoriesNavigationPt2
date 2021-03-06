//
//  StoriesNavigationDismissAnimator.swift
//  StoriesNavigations
//
//  Created by Semyon on 27.11.2020.
//

import UIKit

class StoriesNavigationDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private enum Spec {
        static let animationDuration: TimeInterval = 0.3
    }

    private let endFrame: CGRect

    init(endFrame: CGRect) {
        self.endFrame = endFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Spec.animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromViewController = transitionContext.viewController(forKey: .from),
              let snapshot = fromViewController.view.snapshotView(afterScreenUpdates: true)
        else {
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(snapshot)
        
        fromViewController.view.isHidden = true
        
        UIView.animate(withDuration: Spec.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            snapshot.frame = self.endFrame
            snapshot.alpha = 0
        }, completion: { _ in
            fromViewController.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}

