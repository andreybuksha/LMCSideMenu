//
//  LMCSideMenuCenterControllerProtocol.swift
//  LMCSideMenu
//
//  Created by Andrey Buksha on 14/09/2018.
//  Copyright © 2018 letmecode. All rights reserved.
//

import UIKit


/// Base protocol any center View Controller need conform to. This protocol contains a set of methods and properties required for setting up side menu.
public protocol LMCSideMenuCenterControllerProtocol where Self: UIViewController {
    
    /// MenuTransitionInteractor object that manages all transitions of menu controllers.
    var interactor: MenuTransitionInteractor { get set }
    
    
    /// Sets up Side menu with provided leftMenu and rightMenu
    ///
    /// - Parameters:
    ///   - leftMenu: The View Controller to be used as a left menu. Pass nil to disable left menu
    ///   - rightMenu: The View Controller to be used as a right menu. Pass nil to disable right menu
    func setupMenu(leftMenu: UIViewController?, rightMenu: UIViewController?)
    
    
    /// Presents left menu. Call this method when you need to present left menu programmatically, for example, on menu button tap.
    func presentLeftMenu()
    
    /// Presents right menu. Call this method when you need to present right menu programmatically, for example, on menu button tap.
    func presentRightMenu()
    
    /**
     Enables right screen edge gesture for presenting right menu.
     
     You may provide custom implementation to this method to override default UIScreenEdgePanGestureRecognizer setup.
     */
    func enableLeftMenuGesture()
    
    /**
     Enables right screen edge gesture for presenting right menu.
     
     You may provide custom implementation to this method to override default UIScreenEdgePanGestureRecognizer setup.
     */
    func enableRightMenuGesture()
}

public extension LMCSideMenuCenterControllerProtocol {
    
    func setupMenu(leftMenu: UIViewController?, rightMenu: UIViewController?) {
        interactor.leftMenuController = leftMenu
        interactor.rightMenuController = rightMenu
        
        interactor.centerController = self
        
        leftMenu?.transitioningDelegate = interactor
        rightMenu?.transitioningDelegate = interactor
    }
    
    func enableLeftMenuGesture() {
        interactor.enableLeftMenuGesture(on: view)
    }
    
    func enableRightMenuGesture() {
        interactor.enableRightMenuGesture(on: view)
    }
    
    func presentLeftMenu() {
        if let leftMenu = interactor.leftMenuController {
            interactor.menuPosition = .left
            present(leftMenu, animated: true)
        }
    }
    
    func presentRightMenu() {
        if let rightMenu = interactor.rightMenuController {
            interactor.menuPosition = .right
            present(rightMenu, animated: true)
        }
    }
    
    func transitionMenu(to size: CGSize, coordinator: UIViewControllerTransitionCoordinator) {
        guard interactor.shouldAdjustmenu else { return }
        interactor.prepareForAdjustement()
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.interactor.adjustMenu(to: size)
        }) { [weak self] context in
            self?.interactor.completeAdjusting(to: size)
        }
    }
    
}
