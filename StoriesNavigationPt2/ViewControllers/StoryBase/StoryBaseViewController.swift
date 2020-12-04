//
//  StoryBaseViewController.swift
//  StoriesNavigations
//
//  Created by Semyon on 23.11.2020.
//

import UIKit
import Foundation

public class StoryBaseViewController: UIViewController {
    
    // MARK: - Constants
    private enum Spec {
        static let minVelocityToHide: CGFloat = 1500
        
        enum CloseImage {
            static let size: CGSize = CGSize(width: 40, height: 40)
            static var original: CGPoint = CGPoint(x: 24, y: 50)
        }
    }
    
    // MARK: - UI components
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonAction(sender:)), for: .touchUpInside)
        button.frame = CGRect(origin: Spec.CloseImage.original, size: Spec.CloseImage.size)
        return button
    }()
    
    // MARK: - Private properties
    // 1
    private lazy var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition? = nil
    private lazy var operation: TransitionOperation? = nil
    
    // MARK: - Lifecycle
    public override func loadView() {
        super.loadView()
        setupUI()
    }
    
}

extension StoryBaseViewController {
    
    private func setupUI() {
        // 2
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
        view.addSubview(closeButton)
    }
    
    @objc
    private func closeButtonAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
}

// MARK: UIPanGestureRecognizer
extension StoryBaseViewController: UIGestureRecognizerDelegate {
    
    @objc
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        handleHorizontalSwipe(panGesture: panGesture)
    }
    
    // 3
    private func handleHorizontalSwipe(panGesture: UIPanGestureRecognizer) {
        
        let velocity = panGesture.velocity(in: view)
        // 4 отвечает за прогресс свайпа по экрану, в диапазоне от 0 до 1
        var percent: CGFloat {
            switch operation {
            case .push:
                return abs(min(panGesture.translation(in: view).x, 0)) / view.frame.width
                
            case .pop:
                return max(panGesture.translation(in: view).x, 0) / view.frame.width
                
            default:
                return max(panGesture.translation(in: view).x, 0) / view.frame.width
            }
        }
        
        // 5
        switch panGesture.state {
        case .began:
            // 6
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition?.completionCurve = .easeOut
            
            navigationController?.delegate = self
            if velocity.x > 0 {
                operation = .pop
                navigationController?.popViewController(animated: true)
            } else {
                operation = .push
                
                let nextVC = StoryBaseViewController()
                nextVC.view.backgroundColor = UIColor.random
                navigationController?.pushViewController(nextVC, animated: true)
            }
            
        case .changed:
            // 7
            percentDrivenInteractiveTransition?.update(percent)
            
        case .ended:
            // 8
            if percent > 0.5 || velocity.x > Spec.minVelocityToHide {
                percentDrivenInteractiveTransition?.finish()
            } else {
                percentDrivenInteractiveTransition?.cancel()
            }
            percentDrivenInteractiveTransition = nil
            navigationController?.delegate = nil
            
        case .cancelled, .failed:
            // 9
            percentDrivenInteractiveTransition?.cancel()
            percentDrivenInteractiveTransition = nil
            navigationController?.delegate = nil
            
        default:
            break
        }
    }
    
}

// MARK: UINavigationControllerDelegate    
extension StoryBaseViewController: UINavigationControllerDelegate {
    
    // 1
    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .push:
            return StoryBaseAnimatedTransitioning(operation: .push)
            
        case .pop:
            return StoryBaseAnimatedTransitioning(operation: .pop)
            
        default:
            return nil
        }
    }
    
    // 2
    public func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
    
        return percentDrivenInteractiveTransition
    }
    
}
