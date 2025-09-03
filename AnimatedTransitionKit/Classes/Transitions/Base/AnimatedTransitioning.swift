//
//  AnimatedTransitioning.swift
//  Pods
//
//  Created by Minwoo on 9/4/25.
//

import UIKit


@objcMembers open class AnimatedTransitioning: AbstractAnimatedTransitioning {
    private var isDismissTransitionInitialized = false
    open var isPresenting: Bool = false   // Objective-C 호환성으로 public 사용

    // MARK: - Overridden: AbstractAnimatedTransitioning

    override public var aboveViewController: UIViewController? {
        return isPresenting ? toViewController : fromViewController
    }

    override public var belowViewController: UIViewController? {
        return isPresenting ? fromViewController : toViewController
    }

    override public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(using: transitionContext)

        isDismissTransitionInitialized = !isPresenting

        fromViewController?.modalPresentationCapturesStatusBarAppearance = true
        toViewController?.modalPresentationCapturesStatusBarAppearance = true

        if isAllowsAppearanceTransition && !transitionContext.isInteractive {
            belowViewController?.beginAppearanceTransition(!isPresenting, animated: transitionContext.isAnimated)
        }

        if isPresenting {
            animateTransition(forPresenting: transitionContext)
        } else {
            animateTransition(forDismission: transitionContext)
        }
    }

    override public func clear() {
        if isDismissTransitionInitialized { return }

        if isAllowsDeactivating {
            belowViewController?.view.alpha = 1
            belowViewController?.view.transform = .identity
            belowViewController?.view.tintAdjustmentMode = .normal
            belowViewController?.view.isHidden = false
        }

        if isAllowsAppearanceTransition {
            aboveViewController?.beginAppearanceTransition(false, animated: false)
            belowViewController?.beginAppearanceTransition(true, animated: false)
        }
        
        aboveViewController?.view.removeFromSuperview()

        if isAllowsAppearanceTransition {
            aboveViewController?.endAppearanceTransition()
            belowViewController?.endAppearanceTransition()
        }
    }

    open func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
        // To be overridden by subclasses
    }
    
    open func animateTransition(forPresenting transitionContext: any UIViewControllerContextTransitioning) {
        toViewController?.view.frame = fromViewController?.view.bounds ?? .zero
    }
}
