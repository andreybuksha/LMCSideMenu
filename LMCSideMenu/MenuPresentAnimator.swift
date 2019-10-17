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
        
        let contextView = interactor.presentationContextController?.view ?? containerView
        
        let convertedFrame = contextView.convert(contextView.bounds, to: containerView)
        
        toVc.view.frame.size = CGSize(width: (contextView.frame.width * interactor.menuWidth).rounded(),
                                      height: contextView.frame.height)
                
        guard let fromSnapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else { fatalError() }
        guard let snapshot = toVc.view.snapshotView(afterScreenUpdates: true) else { fatalError() }
        
        fromSnapshot.tag = MenuHelper.presentingSnapshotTag
        
        contextView.addSubview(fromSnapshot)
        contextView.addSubview(snapshot)
        
        let overlayView = createOverlayView(with: fromSnapshot.bounds)
        overlayView.tag = MenuHelper.overlayViewTag
        fromSnapshot.addSubview(overlayView)
        
        toVc.view.frame.origin.y = convertedFrame.minY
        switch interactor.menuPosition {
        case .left:
            toVc.view.frame.origin.x = convertedFrame.minX
            snapshot.frame.origin.x = -toVc.view.frame.width
            
        case .right:
            toVc.view.frame.origin.x = convertedFrame.maxX - toVc.view.frame.width
            snapshot.frame.origin.x = contextView.frame.width
        }
        toVc.view.isHidden = true
        if let superview = toVc.presentingViewController?.view.superview?.superview {
            if #available(iOS 13, *) {
                switch interactor.menuPosition {
                case .left:
                    toVc.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                case .right:
                    toVc.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
            }
            toVc.view.clipsToBounds = true
            toVc.view.layer.cornerRadius = superview.layer.cornerRadius
        }
        containerView.addSubview(toVc.view)
        
        var tapViewFrame: CGRect
        let tapViewWidth = containerView.frame.width - toVc.view.frame.width
        if interactor.menuPosition == .left {
            tapViewFrame = CGRect(x: toVc.view.frame.maxX,
                                  y: toVc.view.frame.minY,
                                  width: tapViewWidth,
                                  height: toVc.view.frame.height)
        } else {
            tapViewFrame = CGRect(x: 0, y: 0, width: tapViewWidth, height: toVc.view.frame.height)
        }
        
        interactor.addTapView(to: containerView, wtih: tapViewFrame)
        
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                              timingParameters: UICubicTimingParameters(animationCurve: .linear))
        animator.addAnimations { [weak self] in
            guard let self = self else { return }
            switch self.interactor.menuPosition {
            case .left:
                snapshot.frame.origin.x = 0
                fromSnapshot.frame.origin.x = snapshot.frame.maxX
            case .right:
                snapshot.frame.origin.x = contextView.frame.width - toVc.view.frame.width
                fromSnapshot.frame.origin.x = -snapshot.frame.width
            }
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
