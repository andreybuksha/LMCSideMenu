//
//  MenuDismissAnimator.swift
//  SideMenu
//
//  Created by Andrey Buksha on 24.05.2018.
//  Copyright © 2018 letmecode. All rights reserved.
//

import UIKit

class MenuDismissAnimator: NSObject {
    
    let interactor: MenuTransitionInteractor
    private var propertyAnimator: UIViewPropertyAnimator?
    
    init(interactor: MenuTransitionInteractor) {
        self.interactor = interactor
        super.init()
    }
    
}

extension MenuDismissAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return MenuHelper.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let propertyAnimator = propertyAnimator {
            return propertyAnimator
        }
        
        guard let fromVC = transitionContext.viewController(forKey: .from) else { fatalError() }
        
        let containerView = transitionContext.containerView
        let contextView = interactor.presentationContextController?.view ?? containerView
        
        guard let presentingSnapshot = contextView.viewWithTag(MenuHelper.presentingSnapshotTag) else { fatalError() }
        let overlayView = presentingSnapshot.viewWithTag(MenuHelper.overlayViewTag)
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { fatalError() }
        if interactor.menuPosition == .right {
            snapshot.frame.origin.x = contextView.frame.width - snapshot.frame.width
        }
        
        contextView.addSubview(snapshot)
        fromVC.view.isHidden = true
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: UICubicTimingParameters(animationCurve: .linear))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            switch self.interactor.menuPosition {
            case .left:
                snapshot.frame.origin.x = -snapshot.frame.width
            case .right:
                snapshot.frame.origin.x = contextView.frame.width
            }
            presentingSnapshot.frame.origin.x = 0
            overlayView?.alpha = 0
        }
        animator.addCompletion { [weak self] _ in
            let didTransitionComplete = !transitionContext.transitionWasCancelled
            snapshot.removeFromSuperview()
            fromVC.view.isHidden = false
            if didTransitionComplete {
                self?.interactor.removeTapView()
                presentingSnapshot.removeFromSuperview()
                NotificationCenter.default.post(name: MenuHelper.menuDidHideNotification, object: nil)
            }
            
            transitionContext.completeTransition(didTransitionComplete)
        }
        propertyAnimator = animator
        return animator
    }
    
}
