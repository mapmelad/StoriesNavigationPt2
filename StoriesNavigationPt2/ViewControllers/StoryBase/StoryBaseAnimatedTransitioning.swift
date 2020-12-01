//
//  StoryBaseAnimatedTransitioning.swift
//  StoriesNavigations
//
//  Created by Semyon on 23.11.2020.
//

import UIKit

enum TransitionOperation {
    case push, pop
}

class StoryBaseAnimatedTransitioning: NSObject {
    
    private enum Spec {
        static let animationDuration: TimeInterval = 0.3
        static let cornerRadius: CGFloat = 10
        static let minimumScale = CGAffineTransform(scaleX: 0.85, y: 0.85)
    }
    
    private let operation: TransitionOperation
    
    init(operation: TransitionOperation) {
        self.operation = operation
    }
    
}

extension StoryBaseAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    // http://fusionblender.net/swipe-transition-between-uiviewcontrollers/
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        /// 1 Получаем вью-контроллеры, которые будут анимировать.
        guard
            let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to)
        else {
            return
        }
        
        /// 2 Получаем доступ к представлению на котором происходит анимация (которое участвует в переходе).
        let containerView = transitionContext.containerView
        containerView.backgroundColor = UIColor.clear
        
        /// 3 Закругляем углы наших вью при транзишене.
        fromVC.view.layer.masksToBounds = true
        fromVC.view.layer.cornerRadius = Spec.cornerRadius
        toVC.view.layer.masksToBounds = true
        toVC.view.layer.cornerRadius = Spec.cornerRadius
        
        /// 4 Отвечает за актуальную ширину containerView
        // Swipe progress == width
        let width = containerView.frame.width

        /// 5 Начальное положение fromVC.view (текущий видимый VC)
        var offsetLeft = fromVC.view.frame

        /// 6 Устанавливаем начальные значения для fromVC и toVC
        switch operation {
        case .push:
            offsetLeft.origin.x = 0
            toVC.view.frame.origin.x = width
            toVC.view.transform = .identity
            
        case .pop:
            offsetLeft.origin.x = width
            toVC.view.frame.origin.x = 0
            toVC.view.transform = Spec.minimumScale
        }
        
        /// 7 Перемещаем toVC.view над/под fromVC.view, в зависимости от транзишена
        switch operation {
        case .push:
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            
        case .pop:
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        // Так как мы уже определили длительность анимации, то просто обращаемся к ней
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
        
            /// 8. Выставляем финальное положение вью-контроллеров для анимации и трансформируем их.
            let moveViews = {
                toVC.view.frame = fromVC.view.frame
                fromVC.view.frame = offsetLeft
            }

            switch self.operation {
            case .push:
                moveViews()
                toVC.view.transform = .identity
                fromVC.view.transform = Spec.minimumScale
                
            case .pop:
                toVC.view.transform = .identity
                fromVC.view.transform = .identity
                moveViews()
            }
            
        }, completion: { _ in
            
            ///9.  Убираем любые возможные трансформации и скругления
            toVC.view.transform = .identity
            fromVC.view.transform = .identity
            
            fromVC.view.layer.masksToBounds = true
            fromVC.view.layer.cornerRadius = 0
            toVC.view.layer.masksToBounds = true
            toVC.view.layer.cornerRadius = 0
     
            /// 10. Если переход был отменен, то необходимо удалить всё то, что успели сделали. То есть необходимо удалить toVC.view из контейнера.
            if transitionContext.transitionWasCancelled {
                toVC.view.removeFromSuperview()
            }
            
            containerView.backgroundColor = .clear
            /// 11. Сообщаем transitionContext о состоянии операции
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    // 12. Время длительности анимации
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Spec.animationDuration
    }
    
}

