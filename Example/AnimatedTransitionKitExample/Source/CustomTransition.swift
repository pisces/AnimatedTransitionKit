//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  CustomTransition.swift
//  AnimatedTransitionKitExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import AnimatedTransitionKit

final class CustomTransition: AnimatedTransition {

    override func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitioning()
    }
    override func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomTransitioning()
    }
}

final class CustomTransitioning: AnimatedTransitioning {
    
    // Write code here for dismission
    override func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write code here for presenting
    override func animateTransition(forPresenting transitionContext: UIViewControllerContextTransitioning) {
    }
    // Write interative transition began code here for dismission or presenting
    override func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition changed code here for dismission or presenting
    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        if isPresenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition cacelled code here for dismission or presenting and call completion after animation finished
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if isPresenting {
            // for presenting
        } else {
            // for dismission
        }
    }
    // Write interative transition completed code here for dismission or presenting and call completion after animation finished
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        if isPresenting {
            // for presenting
        } else {
            // for dismission
        }
    }
}
