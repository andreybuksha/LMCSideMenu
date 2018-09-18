//
//  ViewController.swift
//  LMCSideMenuExample
//
//  Created by Andrey Buksha on 18/09/2018.
//  Copyright © 2018 letmecode. All rights reserved.
//

import UIKit
import LMCSideMenu

//Conform center view controller to LMCSideMenuCenterControllerProtocol protocol in order to get menu functionality
class ViewController: UIViewController, LMCSideMenuCenterControllerProtocol {
    
    var interactor: MenuTransitionInteractor = MenuTransitionInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //init left and right menu controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let leftMenuController = storyboard.instantiateViewController(withIdentifier: String(describing: LeftMenuController.self)) as! LeftMenuController
        let rightMenuController = storyboard.instantiateViewController(withIdentifier: String(describing: RightMenuController.self)) as! RightMenuController
        
        //Setup menu
        setupMenu(leftMenu: leftMenuController, rightMenu: rightMenuController)
        
        //enable screen edge gestures if needed
        enableLeftMenuGesture()
        enableRightMenuGesture()
    }

    @IBAction func onLeftMenuButtonTapped(_ sender: UIButton) {
        presentLeftMenu()
    }
    
    @IBAction func onRightMenuButtonTapped(_ sender: UIButton) {
        presentRightMenu()
    }
    
}

