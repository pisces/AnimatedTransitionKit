//
//  AnimatedNavigationTransitioning.swift
//  Pods
//
//  Created by Minwoo on 9/4/25.
//

import UIKit

open class AnimatedNavigationTransitioning: AbstractAnimatedTransitioning {
    public var appearanceOption: TransitioningAnimationOptions?
    public var disappearanceOption: TransitioningAnimationOptions?
    
    open var isPush: Bool = false {
        didSet {
            options = isPush ? appearanceOption : disappearanceOption
        }
    }

    // MARK: - Overridden: AbstractAnimatedTransitioning

    override public var aboveViewController: UIViewController? {
        return isPush ? toViewController : fromViewController
    }

    override public var belowViewController: UIViewController? {
        return isPush ? fromViewController : toViewController
    }

    override public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        if isPush {
            animateTransition(forPush: transitionContext)
        } else {
            animateTransition(forPop: transitionContext)
        }
    }

    // MARK: - Protected methods

    open func animateTransition(forPop transitionContext: UIViewControllerContextTransitioning) {
        // To be implemented by subclasses
    }

    open func animateTransition(forPush transitionContext: UIViewControllerContextTransitioning) {
        // To be implemented by subclasses
    }
}
