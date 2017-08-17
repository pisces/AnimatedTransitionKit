# UIViewControllerTransitions

[![CI Status](http://img.shields.io/travis/pisces/UIViewControllerTransitions.svg?style=flat)](https://travis-ci.org/pisces/UIViewControllerTransitions)
[![Version](https://img.shields.io/cocoapods/v/UIViewControllerTransitions.svg?style=flat)](http://cocoapods.org/pods/UIViewControllerTransitions)
[![License](https://img.shields.io/cocoapods/l/UIViewControllerTransitions.svg?style=flat)](http://cocoapods.org/pods/UIViewControllerTransitions)
[![Platform](https://img.shields.io/cocoapods/p/UIViewControllerTransitions.svg?style=flat)](http://cocoapods.org/pods/UIViewControllerTransitions)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- It's the very simple library to apply transitioning to between viewcontroller and other viewcontroller

## Features
- Very simple interface and integration
- Independent to view controllers
- Expandable
- Provide transitions three types
- Support percent driven interactive transtion with pan gesture recognizer

## Import

Objective-C
```objective-c
#import <UIViewControllerTransitions/UIViewControllerTransitions.h>
```
Swift
```swift
import UIViewControllerTransitions
```

## Example
![](Screenshot/ExDragDropTransition.gif) ![](Screenshot/ExMoveTransition.gif)

## Using UIViewControllerTransition

### MoveTransition Example

```swift
import UIViewControllerTransitions

class MoveTransitionFirstViewController: UIViewController {
    private lazy var secondViewController: UINavigationController = {
        return UINavigationController(rootViewController: MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        
        let transition = MoveTransition()
        transition.isAllowsInteraction = true
        transition.presentingInteractor?.attach(self, present: secondViewController)
        
        secondViewController.transition = transition
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @IBAction func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

class MoveTransitionSecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
```

### Using percent driven interactive transition for UIViewControllerTransition

```swift
private lazy var secondNavigationController: UINavigationController = {
    UINavigationController(rootViewController: SecondViewController())
}()

override func viewDidLoad() {
    super.viewDidLoad()

    let transition = MoveTransition()
    transition.isAllowsInteraction = true

    // Attach view controller to interactive transition for presenting
    transition.presentingInteractor?.attach(self, present: secondNavigationController)

    secondNavigationController.transition = transition
}
```

### Customizing

```swift
import UIViewControllerTransitions

class CustomTransition: UIViewControllerTransition {
    
    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitioning()
    }
    
    override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitioning()
    }
}

class CustomTransitioning: AnimatedTransitioning {
    
    // Write code here for dismission
    override func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write code here for presenting
    override func animateTransition(forPresenting transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write interative transition began code here for dismission or presenting
    override func interactionBegan(_ interactor: AbstractInteractiveTransition) {
        if self.presenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition changed code here for dismission or presenting
    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        if self.presenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition cacelled code here for dismission or presenting and call completion after animation finished
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if self.presenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition completed code here for dismission or presenting and call completion after animation finished
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if self.presenting {
            // for presenting
        } else {
            // for dismission
        }
    }
}
```

#### Using CustomTransition

```swift
let transition = CustomTransition()
transition.isAllowsInteraction = true
transition.presentingInteractor?.attach(self, present: secondViewController)

secondViewController.transition = transition
present(secondViewController, animated: true, completion: nil)
```

## Using UINavigationControllerTransition

### NavigationMoveTransition Example

```swift
import UIViewControllerTransitions

class NavigationMoveTransitionFirstViewController: UIViewController {
    private lazy var secondViewController: NavigationMoveTransitionSecondViewController = {
        return NavigationMoveTransitionSecondViewController(nibName: "NavigationMoveTransitionSecondView", bundle: .main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close))
        
        let transition = NavigationMoveTransition()
        navigationController?.navigationTransition = transition
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Attach view controller to interactive transition for pushing
        if let navigationController = navigationController {
            navigationController.navigationTransition?.interactor.attach(navigationController, present: secondViewController)
        }
    }
    
    @IBAction func clicked() {
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

class NavigationMoveTransitionSecondViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
    }
}

```

### Using percent driven interactive transition for UINavigationControllerTransition

```swift
private lazy var secondViewController: UIViewController = {
    return SecondViewController()
}()

override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationTransition = NavigationMoveTransition()
}
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        
    // Attach view controller to interactive transition for pushing
    if let navigationController = navigationController {
        navigationController.navigationTransition?.interactor.attach(navigationController, present: secondViewController)
    }
}
```

### Customizing
```swift
import UIViewControllerTransitions

class CustomNavigationTransition: UINavigationControllerTransition {
    override func transitioningForPop() -> AnimatedNavigationTransitioning? {
        return CustomNavigationTransitioning()
    }
    override func transitioningForPush() -> AnimatedNavigationTransitioning? {
        return CustomNavigationTransitioning()
    }
}

class CustomNavigationTransitioning: AnimatedNavigationTransitioning {
    // Write code here for pop without interaction
    override func animateTransition(forPop transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write code here for push without interaction
    override func animateTransition(forPush transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write interative transition began code here for push or pop
    override func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        if isPush {
            // for push
        } else {
            // for pop
        }
    }
    // Write interative transition changed code here for push or pop
    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        if isPush {
            // for push
        } else {
            // for pop
        }
    }
    // Write interative transition cacelled code here for push or pop and call completion after animation finished
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if isPush {
            // for push
        } else {
            // for pop
        }
    }
    // Write interative transition completed code here for push or pop and call completion after animation finished
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if isPush {
            // for push
        } else {
            // for pop
        }
    }
}
```
```

#### Using CustomNavigationTransition

```swift
guard let navigationController = navigationController else {return}

let transition = CustomNavigationTransition()

navigationController.navigationTransition = transition
transition.interactor?.attach(navigationController, present: secondViewController)

navigationController.push(secondViewController, animated: true, completion: nil)
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build UIViewControllerTransitions 3.0.0+.

To integrate UIViewControllerTransitions into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'

target '<Your Target Name>' do
    pod 'UIViewControllerTransitions', '~> 3.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Alamofire into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/UIViewControllerTransitions" ~> 3.0.0
```

Run `carthage update` to build the framework and drag the built `UIViewControllerTransitions.framework` into your Xcode project.

## Requirements

iOS Deployment Target 8.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

UIViewControllerTransitions is available under the MIT license. See the LICENSE file for more info.
