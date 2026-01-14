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
//  FadeTransitioning.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 6/18/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedFadeTransitioning to FadeTransitioning
//

import Foundation

public class FadeTransitioning: AnimatedTransitioning {

    // MARK: - Overridden

    override public func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
        if isAllowsDeactivating {
            toViewController?.view.alpha = 0
        }
        toViewController?.view.isHidden = false

        guard !transitionContext.isInteractive else {
            return
        }

        animate { [weak self] in
            guard let self else { return }
            fromViewController?.view.alpha = 0
            if isAllowsDeactivating {
                toViewController?.view.alpha = 1
                toViewController?.view.tintAdjustmentMode = .normal
            }
        } completion: { [weak self] in
            guard let self else { return }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromViewController?.view.removeFromSuperview()

            if isAllowsAppearanceTransition {
                toViewController?.endAppearanceTransition()
            }
        }
    }

    override public func animateTransition(forPresenting transitionContext: UIViewControllerContextTransitioning) {
        super.animateTransition(forPresenting: transitionContext)

        toViewController?.view.alpha = 0
        if let toView = toViewController?.view {
            transitionContext.containerView.addSubview(toView)
        }

        guard !transitionContext.isInteractive else {
            return
        }

        animate { [weak self] in
            guard let self else { return }
            toViewController?.view.alpha = 1

            if isAllowsDeactivating {
                fromViewController?.view.alpha = 0
                fromViewController?.view.tintAdjustmentMode = .dimmed
            }
        } completion: { [weak self] in
            guard let self else { return }
            if isAllowsDeactivating && !transitionContext.transitionWasCancelled {
                fromViewController?.view.isHidden = true
            }

            if isAllowsAppearanceTransition {
                fromViewController?.endAppearanceTransition()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    override public func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        super.interactionBegan(interactor, transitionContext: transitionContext)

        if isAllowsAppearanceTransition {
            belowViewController?.beginAppearanceTransition(!isPresenting, animated: transitionContext.isAnimated)
        }
    }

    override public func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        let aboveViewAlpha: CGFloat = isPresenting ? 0 : 1

        if isAllowsAppearanceTransition {
            belowViewController?.beginAppearanceTransition(isPresenting, animated: context?.isAnimated == true)
        }

        animate(withDuration: 0.25) { [weak self] in
            guard let self else { return }
            aboveViewController?.view.alpha = aboveViewAlpha

            if isAllowsDeactivating {
                let belowViewAlpha: CGFloat = isPresenting ? 1 : 0
                belowViewController?.view.alpha = belowViewAlpha
                belowViewController?.view.tintAdjustmentMode = isPresenting ? .normal : .dimmed
            }
        } completion: { [weak self] in
            guard let self else { return }
            if isPresenting {
                aboveViewController?.view.removeFromSuperview()
                context?.completeTransition(false)

                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
            } else {
                if isAllowsDeactivating {
                    belowViewController?.view.isHidden = true
                }
                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
                context?.completeTransition(false)
            }
            completion?()
        }
    }

    override public func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        let restrictedPercent = fmin(1, fmax(0, percent))
        super.interactionChanged(interactor, percent: restrictedPercent)

        aboveViewController?.view.alpha = max(0, min(1, isPresenting ? restrictedPercent : 1 - restrictedPercent))

        if isAllowsDeactivating {
            belowViewController?.view.alpha = max(0, min(1, isPresenting ? 1 - restrictedPercent : restrictedPercent))
        }
    }

    override public func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        let aboveViewAlpha: CGFloat = isPresenting ? 1 : 0

        animate { [weak self] in
            guard let self else { return }
            aboveViewController?.view.alpha = aboveViewAlpha

            if isAllowsDeactivating {
                let belowViewAlpha: CGFloat = isPresenting ? 0 : 1
                belowViewController?.view.alpha = belowViewAlpha
                belowViewController?.view.tintAdjustmentMode = isPresenting ? .dimmed : .normal
            }
        } completion: { [weak self] in
            guard let self else { return }
            if isPresenting {
                if isAllowsDeactivating {
                    belowViewController?.view.isHidden = true
                }
                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
                completion?()
                context?.completeTransition(context?.transitionWasCancelled == false)
            } else {
                aboveViewController?.view.removeFromSuperview()
                completion?()
                context?.completeTransition(context?.transitionWasCancelled == false)

                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
            }
        }
    }

    override public func shouldTransition(_ interactor: AbstractInteractiveTransition) -> Bool {
        interactor.translation.y - interactor.translationOffset >= 0
    }

    override public func updateTranslationOffset(_ interactor: AbstractInteractiveTransition) {
        guard let panningInteractor = interactor as? PanningInteractiveTransition,
              let scrollView = panningInteractor.drivingScrollView else {
            return
        }
        panningInteractor.translationOffset = scrollView.contentOffset.y + scrollView.extAdjustedContentInset.top
    }
}
