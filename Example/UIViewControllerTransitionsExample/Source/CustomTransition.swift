//
//  CustomTransition.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

class CustomTransition: AbstractUIViewControllerTransition {
    
    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = AnimatedCustomTransitioning()
        transitioning.duration = 0.4
        return transitioning
    }
    
    override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitioning = AnimatedCustomTransitioning()
        transitioning.duration = 0.4
        transitioning.presenting = true
        return transitioning
    }
}

class AnimatedCustomTransitioning: AnimatedTransitioning {
    
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
