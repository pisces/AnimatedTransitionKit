# AnimatedTransitionKit

![Swift](https://img.shields.io/badge/Swift-5-orange.svg)
![Objective-c](https://img.shields.io/badge/Objective-c-red.svg)
[![Version](https://img.shields.io/cocoapods/v/AnimatedTransitionKit.svg?style=flat)](http://cocoapods.org/pods/AnimatedTransitionKit)
[![License](https://img.shields.io/cocoapods/l/AnimatedTransitionKit.svg?style=flat)](http://cocoapods.org/pods/AnimatedTransitionKit)
[![Platform](https://img.shields.io/cocoapods/p/AnimatedTransitionKit.svg?style=flat)](http://cocoapods.org/pods/AnimatedTransitionKit)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- It's the very simple library to apply transitioning to between scene and other scene

## Features
- Simple integration of custom transitioning for UIViewController and UINavigationController
- Provides various types of custom transitioning
- Support percent driven interactive transtions
- Expandable

## Example
![](Screenshot/ExMoveTransition.gif)&nbsp;&nbsp;&nbsp;
![](Screenshot/ExDragDropTransition.gif)

## Transition types for UIViewController
- Move
- DragDrop
- Fade
- Zoom

## Transition types for UINavigationController
- Move

## Gestures
- Pan
- Pinch

## Import

Objective-C
```objective-c
#import <AnimatedTransitionKit/AnimatedTransitionKit.h>
```
Swift
```swift
import AnimatedTransitionKit
```

## 🔥Using AnimatedTransition

### Using ZoomTransition

```swift
import AnimatedTransitionKit

final class ZoomTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"

        // View binding with any transition id
        button.transitionItem.id = "zoomTarget"
        
        zoomTransition.prepareAppearance(from: self)
    }

    // MARK: - Private

    private lazy var zoomTransition = ZoomTransition()

    @IBOutlet private weak var button: UIButton!
    
    @IBAction private func clicked() {
        present(createSecondVC(), animated: true, completion: nil)
    }
}

extension ZoomTransitionFirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }

    private func createSecondVC() -> UIViewController {
        let rootVC = UIStoryboard(name: "ZoomTransition", bundle: nil).instantiateViewController(withIdentifier: "SecondScene")
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.transition = zoomTransition
        return navigationController
    }
}

final class ZoomTransitionSecondViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        
        // View binding with matched transition id
        targetView.transitionItem.id = "zoomTarget"
    }
    
    // MARK: - Internal
    
    @IBOutlet private(set) weak var targetView: UIView!
    
    // MARK: - Private
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
```

### Using MoveTransition Simply
#### Using single transition for dismission with pan gesture

```swift
import AnimatedTransitionKit

final class ViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.transition = MoveTransition()
    }
}
```

### Using MoveTransition Deeply
#### Using pair transitions for presenting and dismission both with pan gesture

```swift
import AnimatedTransitionKit

final class MoveTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First View"
        moveTransition.prepareAppearance(from: self)
    }

    // MARK: - Private

    private lazy var moveTransition = MoveTransition()

    @IBAction private func clicked() {
        present(createSecondVC(), animated: true, completion: nil)
    }
}

extension MoveTransitionFirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }

    private func createSecondVC() -> UIViewController {
        let rootVC = MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main)
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.transition = moveTransition
        return navigationController
    }
}

final class MoveTransitionSecondViewController: UITableViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        navigationController?.transition?.disappearenceInteractor?.drivingScrollView = tableView
    }
    
    // MARK: - Overridden: UITableViewController
    
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
    
    // MARK: - Private
    
    @objc private func close() {
        dismiss(animated: true)
    }
}

// MARK: - InteractiveTransitionDelegate

extension MoveTransitionSecondViewController: InteractiveTransitionDelegate {
    func shouldTransition(_ interactor: AbstractInteractiveTransition) -> Bool {
        navigationController?.viewControllers.count == 1
    }
}
```

#### Using DragDropTransition

```swift
import AnimatedTransitionKit

final class DragDropTransitionFirstViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        view.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Private
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        UITapGestureRecognizer(target: self, action: #selector(tapped))
    }()
    
    @objc private func tapped() {
        let secondViewController = DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)
        
        let transition = DragDropTransition()
        transition.disappearenceInteractor?.delegate = secondViewController
        
        let w = view.frame.size.width
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = navigationController!.navigationBar.frame.size.height
        let bigRect = CGRect(x: 0, y: statusBarHeight + navigationBarHeight, width: w, height: w)
        let smallRect = imageView.frame
        
        transition.presentingSource = DragDropTransitioningSource.image({ () -> UIImage? in
            self.imageView.image
        }, from: { () -> CGRect in
            smallRect
        }, to: { () -> CGRect in
            bigRect
        }, rotation: { () -> CGFloat in
            0
        }) {
            self.imageView.isHidden = true
            secondViewController.imageView.isHidden = false
        }
        
        transition.dismissionSource = DragDropTransitioningSource.image({ () -> UIImage? in
            secondViewController.imageView.image
        }, from: { () -> CGRect in
            bigRect
        }, to: { () -> CGRect in
            smallRect
        }, rotation: { () -> CGFloat in
            0
        }) {
            self.imageView.isHidden = false
        }
        
        secondNavigationController.transition = transition
        navigationController?.present(secondNavigationController, animated: true, completion: nil)
    }
}

final class DragDropTransitionSecondViewController: UIViewController {
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Internal

    @IBOutlet private(set) weak var imageView: UIImageView!
    
    // MARK: - Private

    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - InteractiveTransitionDelegate

extension DragDropTransitionSecondViewController: InteractiveTransitionDelegate {

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
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteract gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
```

### Customize AnimatedTransition

```swift
import AnimatedTransitionKit

class CustomTransition: AnimatedTransition {
    
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

### Using CustomTransition

```swift
final class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        customTransition.prepareAppearance(from: self)
    }

    private let customTransition = CustomTransition()
    
    @IBAction private func clicked() {
        present(createSecondVC(), animated: true, completion: nil)
    }
}

extension FirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }
    
    private func createSecondVC() -> UIViewController {
        let vc = SecondViewController()
        vc.transition = customTransition
        return vc
    }
}
```

## 🔥Using AnimatedNavigationTransition

### Using NavigationMoveTransition
![](Screenshot/ExNavigationMoveTransition.gif)

```swift
import AnimatedTransitionKit

final class NavigationMoveTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close))
        navigationController?.navigationTransition = {
            $0.interactor?.dataSource = self
            return $0
        }(NavigationMoveTransition())
    }
    
    // MARK: - Private
    
    @IBAction private func clicked() {
        let vc = createSecondVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension NavigationMoveTransitionFirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }

    private func createSecondVC() -> UIViewController {
        NavigationMoveTransitionSecondViewController()
    }
}

final class NavigationMoveTransitionSecondViewController: UITableViewController {
    
    // MARK: - Lifecycle

    init() {
        super.init(nibName: "NavigationMoveTransitionSecondView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
    }
    
    // MARK: - Overridden: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
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
}
```

### Customize AnimatedNavigationTransition
```swift
import AnimatedTransitionKit

class CustomNavigationTransition: UINavigationControllerTransition {
    override func newTransitioning() -> AnimatedNavigationTransitioning? {
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

### Using CustomNavigationTransition

```swift
navigationController.navigationTransition = CustomNavigationTransition()
navigationController.push(secondViewController, animated: true, completion: nil)

final class FirstViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationTransition = {
            $0.interactor?.dataSource = self
            return $0
        }(CustomNavigationTransition())
    }
    
    @IBAction private func clicked() {
        navigationController?.pushViewController(createSecondVC(), animated: true)
    }
}

extension FirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }
    
    private func createSecondVC() -> UIViewController {
        SecondViewController()
    }
}
```

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build AnimatedTransitionKit.

To integrate AnimatedTransitionKit into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target '<Your Target Name>' do
    pod 'AnimatedTransitionKit', '~> 4'
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

To integrate AnimatedTransitionKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pisces/AnimatedTransitionKit" ~> 4
```

Run `carthage update` to build the framework and drag the built `AnimatedTransitionKit.framework` into your Xcode project.

## Requirements

iOS Deployment Target 13.0 higher

## Author

Steve Kim, hh963103@gmail.com

## License

AnimatedTransitionKit is available under the BSD 2-Clause license. See the LICENSE file for more info.
