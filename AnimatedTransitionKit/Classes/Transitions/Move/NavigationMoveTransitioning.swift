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
//  NavigationMoveTransitioning.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 7/15/25.
//

import Foundation

open class NavigationMoveTransitioning: AnimatedNavigationTransitioning {

    // MARK: Lifecycle

    public init(
        direction: MoveTransitioningDirection,
        animationOptions: TransitioningAnimationOptions?)
    {
        self.direction = direction
        self.animationOptions = animationOptions
    }

    // MARK: Open

    override open var isPush: Bool {
        didSet {
            transitioningProxy.isAppearing = isPush
        }
    }

    override open func animateTransition(forPush transitionContext: UIViewControllerContextTransitioning) {
        transitioningProxy.animateTransition(
            fromVC: fromViewController,
            toVC: toViewController,
            transitionContext: transitionContext)
    }

    override open func animateTransition(forPop transitionContext: UIViewControllerContextTransitioning) {
        transitioningProxy.animateTransition(
            fromVC: fromViewController,
            toVC: toViewController,
            transitionContext: transitionContext)
    }

    override open func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        transitioningProxy.interactionChanged(
            interactor,
            percent: percent,
            aboveVC: aboveViewController,
            belowVC: belowViewController,
            transitionContext: context)
    }

    override open func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        transitioningProxy.interactionCompleted(
            interactor,
            transitionContext: context,
            aboveVC: aboveViewController,
            belowVC: belowViewController,
            completion: completion)
    }

    override open func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        transitioningProxy.interactionCancelled(
            interactor,
            transitionContext: context,
            aboveVC: aboveViewController,
            belowVC: belowViewController,
            completion: completion)
    }

    // MARK: Public

    public let direction: MoveTransitioningDirection
    public let animationOptions: TransitioningAnimationOptions?

    // MARK: Private

    private lazy var transitioningProxy = MoveTransitioningProxy(
        direction: direction,
        animationBlock: { [unowned self] duration, animation, completion in
            let duration = duration
                ?? animationOptions?.duration
                ?? UINavigationController.hideShowBarDuration
            animate(withDuration: duration, animations: animation, completion: completion)
        })
}
