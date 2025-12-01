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
//  MoveTransitioningProxy.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 7/15/25.
//

import Foundation

// MARK: - MoveTransitioningProxy

public final class MoveTransitioningProxy {

    // MARK: Lifecycle

    public init(direction: MoveTransitioningDirection, animationBlock: @escaping AnimationBlock) {
        self.direction = direction
        self.animationBlock = animationBlock
    }

    // MARK: Public

    public typealias AnimationBlock = (
        Duration?,
        @escaping Animation,
        @escaping Completion)
        -> Void

    public typealias Duration = TimeInterval
    public typealias Animation = () -> Void
    public typealias Completion = () -> Void

    public var isAppearing = false
    public var direction: MoveTransitioningDirection

    public func animateTransition(
        fromVC: UIViewController?,
        toVC: UIViewController?,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion? = nil)
    {
        guard let fromVC,
              let toVC else { return }

        if isAppearing {
            animateAppearance(
                fromVC: fromVC,
                toVC: toVC,
                transitionContext: transitionContext,
                completion: completion)
        } else {
            animateDisappearance(
                fromVC: fromVC,
                toVC: toVC,
                transitionContext: transitionContext,
                completion: completion)
        }
    }

    public func interactionChanged(
        _ interactor: AbstractInteractiveTransition,
        percent: CGFloat,
        aboveVC: UIViewController?,
        belowVC: UIViewController?,
        transitionContext: UIViewControllerContextTransitioning?)
    {
        guard let transitionContext,
              let aboveVC,
              let belowVC else { return }

        if isAppearing {
            if aboveVC === interactor.viewControllerForAppearing {
                setTransformForAppearance(
                    interactor,
                    percent: percent,
                    aboveVC: aboveVC,
                    belowVC: belowVC,
                    transitionContext: transitionContext)
            }
        } else {
            setTransformForDisappearance(
                interactor,
                percent: percent,
                aboveVC: aboveVC,
                belowVC: belowVC,
                transitionContext: transitionContext)
        }
    }

    public func interactionCompleted(
        _ interactor: AbstractInteractiveTransition,
        transitionContext: UIViewControllerContextTransitioning?,
        aboveVC: UIViewController?,
        belowVC: UIViewController?,
        completion: Completion? = nil)
    {
        guard let transitionContext,
              let aboveVC,
              let belowVC else { return }

        let duration: TimeInterval = 0.15

        if isAppearing {
            if aboveVC === interactor.viewControllerForAppearing {
                startAppearanceIfNeeded(
                    withDuration: duration,
                    fromVC: belowVC,
                    toVC: aboveVC,
                    transitionContext: transitionContext,
                    completion: completion)
            }
        } else {
            startDisappearanceIfNeeded(
                withDuration: duration,
                fromVC: aboveVC,
                toVC: belowVC,
                transitionContext: transitionContext,
                completion: completion)
        }
    }

    public func interactionCancelled(
        _ interactor: AbstractInteractiveTransition,
        transitionContext: UIViewControllerContextTransitioning?,
        aboveVC: UIViewController?,
        belowVC: UIViewController?,
        completion: Completion?)
    {
        guard let transitionContext,
              let aboveVC,
              let belowVC else { return }

        if isAppearing {
            if aboveVC === interactor.viewControllerForAppearing {
                cancelAppearance(
                    aboveVC: aboveVC,
                    belowVC: belowVC,
                    transitionContext: transitionContext,
                    completion: completion)
            }
        } else {
            cancelDisappearance(
                aboveVC: aboveVC,
                belowVC: belowVC,
                transitionContext: transitionContext,
                completion: completion)
        }
    }

    // MARK: Private

    private let animationBlock: AnimationBlock

    private var isVertical: Bool {
        !direction.isHorizontal
    }

}

extension MoveTransitioningProxy {
    private func animateAppearance(
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion? = nil)
    {
        prepareAppearance(
            fromVC: fromVC,
            toVC: toVC,
            transitionContext: transitionContext)
        startAppearanceIfNeeded(
            fromVC: fromVC,
            toVC: toVC,
            transitionContext: transitionContext,
            completion: completion)
    }

    private func prepareAppearance(
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning)
    {
        transitionContext.containerView.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        fromVC.view.transform = belowViewTransformWhileSliding(percent: 0, transitionContext: transitionContext)

        let x = isVertical ? 0 : transitionContext.containerView.bounds.width
        let y = isVertical ? transitionContext.containerView.bounds.height : 0
        toVC.view.frame.origin = .zero
        toVC.view.transform = .init(translationX: x, y: y)

        if direction.isHorizontal {
            toVC.view.applyDropShadow()
        }
    }

    private func startAppearanceIfNeeded(
        withDuration duration: TimeInterval? = nil,
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion? = nil)
    {
        if transitionContext.isInteractive { return }

        animationBlock(
            duration,
            { [weak self] in
                guard let self else { return }
                fromVC.view.transform = belowViewTransformWhileSliding(percent: 1, transitionContext: transitionContext)
                toVC.view.transform = .identity
            },
            {
                if let fromView = transitionContext.view(forKey: .from) {
                    fromView.transform = .identity
                }
                if let toView = transitionContext.view(forKey: .to) {
                    toView.transform = .identity
                    toView.clearDropShadow()
                }
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                completion?()
            })
    }

    private func setTransformForAppearance(
        _ interactor: AbstractInteractiveTransition,
        percent: CGFloat,
        aboveVC: UIViewController,
        belowVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning)
    {
        let x = isVertical ? 0 : transitionContext.containerView.bounds.width + interactor.translation.x
        let y = isVertical ? transitionContext.containerView.bounds.height + interactor.translation.y : 0
        let restrictedX = min(transitionContext.containerView.bounds.width, max(0, x))
        let restrictedY = min(transitionContext.containerView.bounds.height, max(0, y))
        aboveVC.view.transform = .init(translationX: restrictedX, y: restrictedY)
        belowVC.view.transform = belowViewTransformWhileSliding(percent: percent, transitionContext: transitionContext)
    }

    private func cancelAppearance(
        aboveVC: UIViewController,
        belowVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion?)
    {
        animationBlock(
            0.15,
            { [weak self] in
                guard let self else { return }
                let x = isVertical ? 0 : transitionContext.containerView.bounds.width
                let y = isVertical ? transitionContext.containerView.bounds.height : 0
                aboveVC.view.transform = .init(translationX: x, y: y)
                belowVC.view.transform = .identity
            },
            { [weak aboveVC] in
                aboveVC?.view.transform = .identity
                transitionContext.completeTransition(false)
                completion?()
            })
    }
}

extension MoveTransitioningProxy {
    private func animateDisappearance(
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion? = nil)
    {
        prepareDisappearance(
            fromVC: fromVC,
            toVC: toVC,
            transitionContext: transitionContext)
        startDisappearanceIfNeeded(
            fromVC: fromVC,
            toVC: toVC,
            transitionContext: transitionContext,
            completion: completion)
    }

    private func prepareDisappearance(
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning)
    {
        insertToContainerViewIfNeeded(transitionContext.containerView, fromVC: fromVC, toVC: toVC)
        toVC.view.layoutIfNeeded()
        fromVC.view.transform = .identity
        toVC.view.transform = belowViewTransformWhileSliding(percent: 0, transitionContext: transitionContext)

        if direction.isHorizontal {
            fromVC.view.applyDropShadow()
        }
    }

    private func startDisappearanceIfNeeded(
        withDuration duration: TimeInterval? = nil,
        fromVC: UIViewController,
        toVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion?)
    {
        if transitionContext.isInteractive { return }

        animationBlock(
            duration,
            { [weak self] in
                guard let self else { return }
                let x = isVertical ? 0 : transitionContext.containerView.bounds.width
                let y = isVertical ? transitionContext.containerView.bounds.height : 0
                fromVC.view.transform = .init(translationX: x, y: y)
                toVC.view.transform = .identity
            },
            {
                if let fromView = transitionContext.view(forKey: .from) {
                    fromView.transform = .identity
                    fromView.clearDropShadow()
                }
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                completion?()
            })
    }

    private func insertToContainerViewIfNeeded(
        _ containerView: UIView,
        fromVC: UIViewController,
        toVC: UIViewController)
    {
        guard toVC.view.superview == nil else { return }
        containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
    }

    private func setTransformForDisappearance(
        _ interactor: AbstractInteractiveTransition,
        percent: CGFloat,
        aboveVC: UIViewController,
        belowVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning)
    {
        let x = isVertical ? 0 : interactor.translation.x
        let y = isVertical ? interactor.translation.y : 0
        let restrictedX = min(transitionContext.containerView.bounds.width, max(0, x))
        let restrictedY = min(transitionContext.containerView.bounds.height, max(0, y))
        aboveVC.view.transform = .init(translationX: restrictedX, y: restrictedY)
        belowVC.view.transform = belowViewTransformWhileSliding(percent: percent, transitionContext: transitionContext)
    }

    private func cancelDisappearance(
        aboveVC: UIViewController,
        belowVC: UIViewController,
        transitionContext: UIViewControllerContextTransitioning,
        completion: Completion?)
    {
        animationBlock(
            0.15,
            { [weak self] in
                guard let self else { return }
                aboveVC.view.transform = .identity
                belowVC.view.transform = belowViewTransformWhileSliding(percent: 0, transitionContext: transitionContext)
            },
            { [weak belowVC] in
                belowVC?.view.transform = .identity
                transitionContext.completeTransition(false)
                completion?()
            })
    }
}

extension MoveTransitioningProxy {
    private func belowViewTransformWhileSliding(
        percent: CGFloat,
        transitionContext: UIViewControllerContextTransitioning)
        -> CGAffineTransform
    {
        if direction.isHorizontal {
            let bounds = transitionContext.containerView.bounds.width * 0.3
            let x = if isAppearing {
                -bounds * percent
            } else {
                -(bounds - (bounds * percent))
            }
            let restrictedX = min(0, max(-bounds, x))
            return .init(translationX: restrictedX, y: 0)
        } else {
            return .identity
        }
    }
}

extension UIView {
    fileprivate func applyDropShadow() {
        layer.shadowOffset = .init(width: -1, height: -1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.3
    }

    fileprivate func clearDropShadow() {
        layer.shadowOffset = .zero
        layer.shadowColor = nil
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
    }
}
