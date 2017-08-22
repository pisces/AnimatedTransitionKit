//
//  CustomNavigationTransition.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 17/08/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

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
