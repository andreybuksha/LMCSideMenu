# LMCSideMenu
Simple and lightweight side menu written in Swift

![](https://github.com/andreybuksha/LMCSideMenu/raw/master/demo.gif)

## Requirements
- iOS 10 or higher version.
- Xcode 10 or higher version.
- Swift 4.2 or higher version.

## Installation
### Cocoapods

`pod 'LMCSideMenu'`

## Usage
First, you need to comform your center view controller to protocol LMCSideMenuCenterControllerProtocol
```
class ViewController: UIViewController, LMCSideMenuCenterControllerProtocol {
    
    var interactor: MenuTransitionInteractor = MenuTransitionInteractor()
    
}
```

Next, setup menu with left and right menu view controllers
```
let storyboard = UIStoryboard(name: "Main", bundle: nil)

let leftMenuController = storyboard.instantiateViewController(withIdentifier: String(describing: LeftMenuController.self)) as! LeftMenuController
let rightMenuController = storyboard.instantiateViewController(withIdentifier: String(describing: RightMenuController.self)) as! RightMenuController

//Setup menu
setupMenu(leftMenu: leftMenuController, rightMenu: rightMenuController)
```

If you need to use screen edge gestures, you can enable them as following:
```
enableLeftMenuGesture()
enableRightMenuGesture()
```

## Customizing
If you need to customize the appearance properties of menu, such as menuWidth, gesture percent threshold or animationDuration, call these methods:
```
MenuHelper.set(menuWidth: newMenuWidth)
MenuHelper.set(percentThreshold: newPercentThreshold)
MenuHelper.set(animationDuration: newAnimationDuration)
```


