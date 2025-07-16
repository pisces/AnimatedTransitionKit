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
//  MoveTransition.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 7/15/25.
//

import Foundation

open class MoveTransition: AnimatedTransition {

    // MARK: Open

    override open func initProperties() {
        super.initProperties()
        direction = .left
    }

    override open func transitioningFor(
        forPresentedController presented: UIViewController?,
        presenting: UIViewController?,
        sourceController source: UIViewController?)
        -> AnimatedTransitioning?
    {
        MoveTransitioning(direction: direction, animationOptions: appearenceOptions)
    }

    override open func transitioning(
        forDismissedController dismissed: UIViewController?)
        -> AnimatedTransitioning?
    {
        MoveTransitioning(direction: direction, animationOptions: disappearenceOptions)
    }

    override open func isAppearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        interactiveTransitionProxy.isAppearing(interactor)
    }

    override open func isDisappearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        interactiveTransitionProxy.isDisappearing(interactor)
    }

    override open func shouldCompleteInteractor(_ interactor: AbstractInteractiveTransition) -> Bool {
        interactiveTransitionProxy.shouldCompleteInteractor(interactor, transition: self)
    }

    // MARK: Public

    public var direction: MoveTransitioningDirection = .left {
        didSet {
            let interactorDirection = direction.toInteractorDirection()
            appearenceInteractor?.direction = interactorDirection
            disappearenceInteractor?.direction = interactorDirection
        }
    }

    // MARK: Private

    private lazy var interactiveTransitionProxy = MoveInteractiveTransitionProxy(direction: direction)
}
