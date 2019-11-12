//
//  Interactor.swift
//  SideMenu
//
//  Created by Andrey Buksha on 22.05.2018.
//  Copyright © 2018 letmecode. All rights reserved.
//

import UIKit

public class MenuTransitionInteractor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false

    var leftMenuController: UIViewController?
    var rightMenuController: UIViewController?

    weak var centerController: (UIViewController & LMCSideMenuCenterControllerProtocol)?
    internal weak var presentationContextController: UIViewController?

    var menuWidth: CGFloat = MenuHelper.menuWidth
    var menuPosition: SideMenuPosition = .left

    private var shouldDismissMenu: Bool {
        return leftMenuController?.viewIfLoaded?.window != nil || rightMenuController?.viewIfLoaded?.window != nil
    }

    private weak var tapView: UIView?

    private lazy var leftEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let leftEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                            action: #selector(handleLeftEdgePan(_:)))
        leftEdgePanGestureRecognizer.edges = .left
        return leftEdgePanGestureRecognizer
    }()
    private lazy var rightEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer = {
        let rightEdgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self,
                                                                             action: #selector(handleRightEdgePan(_:)))
        rightEdgePanGestureRecognizer.edges = .right
        return rightEdgePanGestureRecognizer
    }()

    override public init() {
        super.init()
        setupObservers()
    }
    
    func dismissMenu() {
        guard shouldDismissMenu else { return }
        if menuPosition == .left {
            leftMenuController?.dismiss(animated: true)
        } else {
            rightMenuController?.dismiss(animated: true)
        }
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarFrameChanged(notification:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarFrameChanged(notification:)), name: UIApplication.willChangeStatusBarFrameNotification, object: nil)
    }

    internal func addTapView(to containerView: UIView, wtih frame: CGRect) {
        let tapView = UIView(frame: frame)
        tapView.tag = 1000003
        containerView.addSubview(tapView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapView.addGestureRecognizer(tapGestureRecognizer)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismissPan(_:)))
        tapView.addGestureRecognizer(panGestureRecognizer)

        self.tapView = tapView
    }

    internal func enableLeftMenuGesture(on view: UIView) {
        view.addGestureRecognizer(leftEdgePanGestureRecognizer)
    }

    internal func enableRightMenuGesture(on view: UIView) {
        view.addGestureRecognizer(rightEdgePanGestureRecognizer)
    }

    internal func disableLeftMenuGesture(on view: UIView) {
        view.removeGestureRecognizer(leftEdgePanGestureRecognizer)
    }

    internal func disableRightMenuGesture(on view: UIView) {
        view.removeGestureRecognizer(rightEdgePanGestureRecognizer)
    }

    internal func prepareForAdjustement() {
        guard let tapView = self.tapView else { return }
        guard let containerView = tapView.superview else { return }

        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.tag = MenuHelper.blurViewTag
        guard let snapshotView = containerView.viewWithTag(MenuHelper.presentingSnapshotTag) else { return }
        blurView.frame = snapshotView.frame
        blurView.alpha = 0
        containerView.addSubview(blurView)
        UIView.animate(withDuration: 0.1) {
            blurView.alpha = 1
        }
    }

    internal func adjustMenu(to size: CGSize) {
        var presentedMenuView: UIView?
        if leftMenuController?.viewIfLoaded?.window != nil {
            presentedMenuView = leftMenuController?.view
        } else if rightMenuController?.viewIfLoaded?.window != nil {
            presentedMenuView = rightMenuController?.view
        }
        guard let menuView = presentedMenuView else { return }

        guard let tapView = self.tapView else { return }
        guard let containerView = tapView.superview else { return }
        guard let snapshotView = containerView.viewWithTag(MenuHelper.presentingSnapshotTag) else { return }
        guard let overlayView = snapshotView.subviews.first else { return }

        menuView.frame.size.width = size.width * MenuHelper.menuWidth

        let blurView = containerView.viewWithTag(MenuHelper.blurViewTag)

        let snapshotOrigin: CGPoint
        if menuPosition == .left {
            snapshotOrigin = CGPoint(x: menuView.frame.width, y: snapshotView.frame.origin.y)
        } else {
            snapshotOrigin = CGPoint(x: -menuView.frame.width, y: 0)
        }
        let snapshotFrame = CGRect(origin: snapshotOrigin, size: size)

        let tapViewFrame: CGRect
        let tapViewWidth = size.width - menuView.frame.width
        if menuPosition == .left {
            tapViewFrame = CGRect(x: menuView.frame.width, y: menuView.frame.origin.y, width: tapViewWidth, height: size.height)
        } else {
            tapViewFrame = CGRect(x: 0, y: 0, width: tapViewWidth, height: size.height)
        }

        snapshotView.frame = snapshotFrame
        overlayView.frame = snapshotView.bounds
        tapView.frame = tapViewFrame
        blurView?.frame = tapViewFrame

        if menuPosition == .right {
            menuView.frame.origin.x = size.width - menuView.frame.width
        }
    }

    internal func adjustMenu(statusBarHeightDiff: CGFloat) {
        var presentedMenuView: UIView?
        if leftMenuController?.viewIfLoaded?.window != nil {
            presentedMenuView = leftMenuController?.view
        } else if rightMenuController?.viewIfLoaded?.window != nil {
            presentedMenuView = rightMenuController?.view
        }
        guard let menuView = presentedMenuView else { return }

        menuView.frame.size.height -= statusBarHeightDiff
        menuView.frame.origin.y += statusBarHeightDiff
        menuView.layoutIfNeeded()
    }

    internal func completeAdjusting(to size: CGSize) {
        centerController?.view.frame.size = size

        guard let tapView = self.tapView else { return }
        guard let containerView = tapView.superview else { return }
        guard let snapshotView = containerView.viewWithTag(MenuHelper.presentingSnapshotTag) else { return }

        let snapshotOrigin = snapshotView.frame.origin

        if let snapshot = centerController?.view.snapshotView(afterScreenUpdates: true) {
            snapshot.frame.origin = snapshotOrigin
            snapshotView.removeFromSuperview()
            snapshot.tag = MenuHelper.presentingSnapshotTag
            containerView.insertSubview(snapshot, belowSubview: tapView)

            let overlayView = UIView(frame: snapshot.bounds)
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            snapshot.addSubview(overlayView)
        }

        let blurView = containerView.viewWithTag(MenuHelper.blurViewTag)
        UIView.animate(withDuration: 0.1, animations: {
            blurView?.alpha = 0
        }) { _ in
            blurView?.removeFromSuperview()
        }
    }

    @objc func handleLeftEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        handlePresentPan(direction: .right, sender: sender)
    }

    @objc func handleRightEdgePan(_ sender: UIScreenEdgePanGestureRecognizer) {
        handlePresentPan(direction: .left, sender: sender)
    }

    @objc func statusBarFrameChanged(notification: NSNotification) {
        dismissMenu()
    }

    internal func removeTapView() {
        tapView?.removeFromSuperview()
    }

    @objc private func handleTap() {
        dismissMenu()
    }

    private func handlePresentPan(direction: MenuPanDirection, sender: UIScreenEdgePanGestureRecognizer) {
        guard let view = sender.view else { return }

        let translation = sender.translation(in: view)

        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: direction)

        MenuHelper.map(gestureState: sender.state, to: self, progress: progress, direction: .left) { [weak self] in
            direction == .left ?
                self?.centerController?.presentRightMenu() :
                self?.centerController?.presentLeftMenu()
        }
    }

    @objc private func handleDismissPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: tapView)

        let direction: MenuPanDirection =  menuPosition == .left ? .left : .right

        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: tapView?.bounds ?? .zero, direction: direction)

        MenuHelper.map(gestureState: sender.state, to: self, progress: progress, direction: direction) { [weak self] in
            if self?.menuPosition == .left {
                self?.leftMenuController?.dismiss(animated: true)
            } else {
                self?.rightMenuController?.dismiss(animated: true)
            }
        }
    }
}

extension MenuTransitionInteractor: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuPresentAnimator(interactor: self)
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return MenuDismissAnimator(interactor: self)
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.hasStarted ? self : nil
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.hasStarted ? self : nil
    }

}
