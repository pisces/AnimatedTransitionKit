//
//  AbstractAnimatedTransitioning.swift
//  Pods
//
//  Created by Minwoo on 9/8/25.
//
import UIKit

@objcMembers open class AbstractAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    // MARK: - Properties

    public var isAllowsDeactivating: Bool = false
    public var isAllowsAppearanceTransition: Bool = false
    public var options: TransitioningAnimationOptions?
    public var isAnimating: Bool = false
    
    public weak var context: UIViewControllerContextTransitioning?
    public weak var fromViewController: UIViewController?
    public weak var toViewController: UIViewController?

    private(set) var percentOfCompletion: CGFloat = 0
    private(set) var percentOfInteraction: CGFloat = 0
    private weak var interactor: AbstractInteractiveTransition?

        
    var heightRatio: CGFloat {
        UIScreen.main.bounds.height / 667
    }
    
    var widthRatio: CGFloat {
        UIScreen.main.bounds.width / 375
    }
    
    var belowViewController: UIViewController? {
        return nil
    }
    
    var aboveViewController: UIViewController? {
        return nil
    }
    

    // MARK: - UIViewControllerAnimatedTransitioning

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
        fromViewController = transitionContext.viewController(forKey: .from)
        toViewController = transitionContext.viewController(forKey: .to)
        startAnimating()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return options?.duration ?? 0.3  // TODO: Default duration if options is not set
    }

    public func animationEnded(_ transitionCompleted: Bool) {
        endAnimating()
    }

    // MARK: - Animation Methods

    open func animate(_ animations: @escaping (() -> Void), completion: (() -> Void)?) {
        guard let options else {
            return
        }
        
        animate(withDuration: options.duration, animations: animations, completion: completion)
    }

    open func animate(withDuration duration: TimeInterval, animations: @escaping (() -> Void), completion: (() -> Void)?) {
        guard let options else {
            return
        }
        
        if options.isUsingSpring {
            UIView.animate(withDuration: options.duration,
                           delay: options.delay,
                           usingSpringWithDamping: options.usingSpringWithDamping,
                           initialSpringVelocity: options.initialSpringVelocity,
                           options: [options.animationOptions, .allowUserInteraction],
                           animations: animations) { _ in
                completion?()
            }
        } else {
            UIView.animate(withDuration: options.duration,
                           delay: options.delay,
                           options: [options.animationOptions, .allowUserInteraction],
                           animations: animations) { _ in
                completion?()
            }
        }
    }

    // MARK: - Interactor Methods

    @objc public func storeInteractor(_ interactor: AbstractInteractiveTransition?) {
        self.interactor = interactor
    }

    @objc public func clear() {
        // To be implemented by subclasses
    }

    @objc open func endAnimating() {
        interactor?.clear()
        isAnimating = false
        percentOfInteraction = 0
        percentOfCompletion = 0
    }

    @objc open func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        context = transitionContext
    }

    @objc open func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        // To be implemented by subclasses
    }

    @objc open func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        percentOfInteraction = percent
        percentOfCompletion = percent / interactor.percentForCompletion
    }

    @objc open func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        // To be implemented by subclasses
    }

    @objc public func shouldTransition(_ interactor: AbstractInteractiveTransition) -> Bool {
        return true
    }

    @objc public func startAnimating() {
        isAnimating = true
    }

    @objc public func updateTranslationOffset(_ interactor: AbstractInteractiveTransition) {
        // To be implemented by subclasses
    }
}
