# UIViewControllerTransitions

![Swift](https://img.shields.io/badge/Swift-5-orange.svg)
![Objective-c](https://img.shields.io/badge/Objective-c-red.svg)
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

## Example
![](Screenshot/ExMoveTransition.gif)&nbsp;&nbsp;&nbsp;
![](Screenshot/ExDragDropTransition.gif)

## Transition Types
- Move
- DragDrop
- Fade
- Zoom

## Navigation Transition Types
- Move

## Gestures
- Pan
- Pinch

## Import

Objective-C
```objective-c
#import <UIViewControllerTransitions/UIViewControllerTransitions.h>
```
Swift
```swift
import UIViewControllerTransitions
```

## 🔥Using UIViewControllerTransition

### Pinch Zoom Example

```swift

import UIViewControllerTransitions

final class ZoomTransitionFirstViewController: UIViewController {
    
    @IBOutlet private weak var button: UIButton!
    
    private lazy var secondViewController: UINavigationController = {
        let rootViewController = UIStoryboard(name: "ZoomTransition", bundle: nil).instantiateViewController(withIdentifier: "SecondScene")
        return UINavigationController(rootViewController: rootViewController)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"

        // View binding with any transition id
        button.transition.id = "zoomTarget"
        
        let transition = ZoomTransition()
        transition.isAllowsInteraction = true
        transition.appearenceInteractor?.attach(self, present: secondViewController)
        
        secondViewController.transition = transition
    }
    
    @IBAction func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

final class ZoomTransitionSecondViewController: UIViewController {
    
    @IBOutlet private(set) weak var targetView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        
        // View binding with matched transition id
        targetView.transition.id = "zoomTarget"
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

```

### MoveTransition Example 1
#### Using transition for dismission with swipe gesture.

```swift
import UIViewControllerTransitions

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let transition = MoveTransition()
        transition.isAllowsInteraction = true
        
        navigationController?.transition = transition
    }
}
```

### MoveTransition Example 2
#### Using transition for presenting and dismission both with swipe gesture.

```swift
import UIViewControllerTransitions

final class MoveTransitionFirstViewController: UIViewController, InteractiveTransitionDelegate {
    
    // MARK: - Private Properties
    
    private lazy var secondViewController: UINavigationController = {
        let viewController = MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main)
        let transition = MoveTransition()
        transition.appearenceOptions.duration = 0.25
        transition.disappearenceOptions.duration = 0.35
        transition.isAllowsInteraction = true
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.transition = transition
        return navigationController
    }()
    
    // MARK: - Overridden: UITableViewController (Life Cycle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        
        secondViewController.transition?.appearenceInteractor?.attach(self, present: secondViewController)
    }
    
    // MARK: - Private Selectors
    
    @IBAction func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

final class MoveTransitionSecondViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var isInteractionBegan = false
    private var isViewAppeared = false
    
    // MARK: - Overridden: UITableViewController (Life Cycle)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        navigationController?.transition?.disappearenceInteractor?.delegate = self
    }
    
    // MARK: - Overridden: UITableViewController (UITableView DataSource & Delegate)
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = "\(indexPath.row + 1)"
    }
    
    // MARK: - Private Selectors
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension MoveTransitionSecondViewController: InteractiveTransitionDelegate {
    func shouldChange(withInteractor interactor: AbstractInteractiveTransition) -> Bool {
        return tableView.contentOffset.y + 88 <= 0
    }
    func interactor(_ interactor: AbstractInteractiveTransition, gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    transition.appearenceInteractor?.attach(self, present: secondNavigationController)

    secondNavigationController.transition = transition
}
```

#### DragDropTransition Example

```swift
import UIViewControllerTransitions

class DragDropTransitionFirstViewController: UIViewController {
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(tapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func tapped() {
        let secondViewController = DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)
        
        let transition = DragDropTransition()
        transition.isAllowsInteraction = true
        transition.disappearenceInteractor?.delegate = secondViewController
        
        let w = view.frame.size.width
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = navigationController!.navigationBar.frame.size.height
        let bigRect = CGRect(x: 0, y: statusBarHeight + navigationBarHeight, width: w, height: w)
        let smallRect = imageView.frame
        
        transition.presentingSource = DragDropTransitioningSource.image({ () -> UIImage? in
            return self.imageView.image
        }, from: { () -> CGRect in
            return smallRect
        }, to: { () -> CGRect in
            return bigRect
        }, rotation: { () -> CGFloat in
            return 0
        }) {
            self.imageView.isHidden = true
            secondViewController.imageView.isHidden = false
        }
        
        transition.dismissionSource = DragDropTransitioningSource.image({ () -> UIImage? in
            return secondViewController.imageView.image
        }, from: { () -> CGRect in
            return bigRect
        }, to: { () -> CGRect in
            return smallRect
        }, rotation: { () -> CGFloat in
            return 0
        }) {
            self.imageView.isHidden = false
        }
        
        secondNavigationController.transition = transition
        navigationController?.present(secondNavigationController, animated: true, completion: nil)
    }
}

class DragDropTransitionSecondViewController: UIViewController, InteractiveTransitionDelegate {
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        edgesForExtendedLayout = .bottom
        imageView.isHidden = true
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageViewHeight.constant = view.frame.size.width
    }
    
    // MARK: - InteractiveTransition delegate
    
    func didBegin(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = true
    }
    func didChange(withInteractor interactor: AbstractInteractiveTransition, percent: CGFloat) {
    }
    func didCancel(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func didComplete(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func interactor(_ interactor: AbstractInteractiveTransition, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch?) -> Bool {
        return true
    }
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteractionWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIBarButtonItem selector
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
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
transition.appearenceInteractor?.attach(self, present: secondViewController)

secondViewController.transition = transition
present(secondViewController, animated: true, completion: nil)
```

## 🔥Using UINavigationControllerTransition

### NavigationMoveTransition Example
![](Screenshot/ExNavigationMoveTransition.gif)

```swift
import UIViewControllerTransitions

class NavigationMoveTransitionFirstViewController: UIViewController {
    private lazy var secondViewController: NavigationMoveTransitionSecondViewController = {
        return NavigationMoveTransitionSecondViewController(nibName: "NavigationMoveTransitionSecondView", bundle: .main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close))ㅣ
        navigationController?.navigationTransition = NavigationMoveTransition()
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
platform :ios, '9.0'

target '<Your Target Name>' do
    pod 'UIViewControllerTransitions', '~> 3.1.0'
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

To integrate UIViewControllerTransitions into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/UIViewControllerTransitions" ~> 3.1.0
```

Run `carthage update` to build the framework and drag the built `UIViewControllerTransitions.framework` into your Xcode project.

## Requirements

iOS Deployment Target 9.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

UIViewControllerTransitions is available under the BSD 2-Clause license. See the LICENSE file for more info.
