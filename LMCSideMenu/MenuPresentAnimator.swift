//
//  MenuPresentAnimator.swift
//  SideMenu
//
//  Created by Andrey Buksha on 22.05.2018.
//  Copyright © 2018 letmecode. All rights reserved.
//

import UIKit

class MenuPresentAnimator: NSObject {
    
    let interactor: MenuTransitionInteractor
    private var propertyAnimator: UIViewPropertyAnimator?
    
    init(interactor: MenuTransitionInteractor) {
        self.interactor = interactor
        super.init()
    }

}

extension MenuPresentAnimator: UIViewControllerAnimatedTransitioning {
    
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
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVc = transitionContext.viewController(forKey: .to) else { fatalError() }
        
        let containerView = transitionContext.containerView
        
        toVc.view.frame.size = CGSize(width: (containerView.frame.width * MenuHelper.menuWidth).rounded(), height: containerView.frame.height)
        if interactor.menuPosition == .right {
            toVc.view.frame.origin.x = containerView.frame.width - toVc.view.frame.width
        }
        
        guard let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { fatalError() }
        guard let snapshot = toVc.view.snapshotView(afterScreenUpdates: true) else { fatalError() }
        
        let snapshotContainerView = UIView(frame: containerView.bounds)
        snapshotContainerView.tag = MenuHelper.presentingSnapshotTag
        fromSnapshot.frame.origin.y = snapshotContainerView.frame.height - fromSnapshot.frame.height
        snapshotContainerView.addSubview(fromSnapshot)
        
        containerView.addSubview(snapshotContainerView)
        
        let overlayView = createOverlayView(with: snapshotContainerView.bounds)
        overlayView.tag = MenuHelper.overlayViewTag
        snapshotContainerView.addSubview(overlayView)
        
        snapshot.tag = MenuHelper.menuSnapshotTag
        snapshot.frame.origin.x = interactor.menuPosition == .left ? -snapshot.frame.width : containerView.frame.width
        containerView.addSubview(snapshot)
        toVc.view.isHidden = true
        containerView.insertSubview(toVc.view, aboveSubview: snapshot)
        
        var tapViewFrame: CGRect
        let tapViewWidth = containerView.frame.width - toVc.view.frame.width
        if interactor.menuPosition == .left {
            tapViewFrame = CGRect(x: toVc.view.frame.maxX, y: toVc.view.frame.minY, width: tapViewWidth, height: toVc.view.frame.height)
        } else {
            tapViewFrame = CGRect(x: 0, y: 0, width: tapViewWidth, height: toVc.view.frame.height)
        }
        
        interactor.addTapView(to: containerView, wtih: tapViewFrame)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: UICubicTimingParameters(animationCurve: .linear))
        animator.addAnimations { [weak self] in
            snapshot.frame.origin.x = self?.interactor.menuPosition == .left ? 0 : containerView.frame.width - toVc.view.frame.width
            snapshotContainerView.frame.origin.x = self?.interactor.menuPosition == .left ? snapshot.frame.width : -snapshot.frame.width
            overlayView.alpha = 1
        }
        animator.addCompletion { _ in
            toVc.view.isHidden = false
            if !transitionContext.transitionWasCancelled {
                snapshot.removeFromSuperview()
                NotificationCenter.default.post(name: MenuHelper.menuDidShowNotification, object: nil)
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        self.propertyAnimator = animator
        return animator
    }
    
    private func createOverlayView(with frame: CGRect) -> UIView {
        let overlayView = UIView(frame: frame)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0
        return overlayView
    }
    
}
