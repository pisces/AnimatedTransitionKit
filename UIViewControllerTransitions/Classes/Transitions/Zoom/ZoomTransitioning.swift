//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2021, Steve Kim
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
//  ZoomTransitioning.swift
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2020/12/10.
//

import Foundation

final class ZoomTransitioning: AnimatedTransitioning {
    
    // MARK: Internal
    
    override func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = fromViewController,
              let toVC = toViewController,
              let id = fromVC.view.transition.findID(),
              let fromView = fromVC.view.transition.find(withID: id),
              let toView = toVC.view.transition.find(withID: id),
              let snapshotView = fromView.snapshotView(afterScreenUpdates: true) else { return }
        
        let center = toView.superview?.convert(
            toView.center,
            to: transitionContext.containerView) ?? .zero
        let transform = CGAffineTransform(
            scaleX: toView.bounds.size.width / fromView.bounds.size.width,
            y: toView.bounds.size.height / fromView.bounds.size.height)
        
        snapshotView.center = fromView.center
        fromVC.view.alpha = 1
        fromView.isHidden = true
        toView.isHidden = true
        
        transitionContext.containerView.addSubview(snapshotView)
        
        self.transform = transform
        self.fromView = fromView
        self.snapshotView = snapshotView
        self.toView = toView
        
        if transitionContext.isInteractive { return }
        
        animate({ [weak self] in
            fromVC.view.alpha = 0
            snapshotView.center = center
            snapshotView.transform = transform
            if self?.isAllowsDeactivating == true {
                toVC.view.tintAdjustmentMode = .normal
            }
        },
        completion: { [weak self] in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            fromVC.view.removeFromSuperview()

            if self?.isAllowsAppearanceTransition == true {
                toVC.endAppearanceTransition()
            }
            
            self?.removeSnapshotView()
            fromView.isHidden = false
            toView.isHidden = false
        })
    }
    
    override func animateTransition(forPresenting transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = fromViewController,
              let toVC = toViewController,
              let id = fromVC.view.transition.findID() else { return }

        let toVisibleVC = (toVC as? UINavigationController)?.visibleViewController ?? toVC
        
        guard let fromView = fromVC.view.transition.find(withID: id),
              let snapshotView = fromView.snapshotView(afterScreenUpdates: true),
              let toView = toVisibleVC.view.transition.find(withID: id) else { return }

        transitionContext.containerView.addSubview(toVC.view)
        transitionContext.containerView.addSubview(snapshotView)
        toVC.view.layoutIfNeeded()
        
        let center = toView.superview?.convert(
            toView.center,
            to: transitionContext.containerView) ?? .zero
        let transform = CGAffineTransform(
            scaleX: toView.bounds.size.width / fromView.bounds.size.width,
            y: toView.bounds.size.height / fromView.bounds.size.height)
        
        snapshotView.center = fromView.superview?.convert(fromView.center, to: transitionContext.containerView) ?? .zero
        toVC.view.alpha = 0
        fromView.isHidden = true
        toView.isHidden = true
        
        self.transform = transform
        self.fromView = fromView
        self.snapshotView = snapshotView
        self.toView = toView
        
        if transitionContext.isInteractive { return }
        
        animate({ [weak self] in
            toVC.view.alpha = 1
            snapshotView.center = center
            snapshotView.transform = transform
            if self?.isAllowsDeactivating == true {
                fromVC.view.tintAdjustmentMode = .dimmed
            }
        },
        completion: { [weak self] in
            fromView.isHidden = false
            toView.isHidden = false
            if self?.isAllowsAppearanceTransition == true {
                fromVC.endAppearanceTransition()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self?.removeSnapshotView()
        })
    }
    
    override func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        super.interactionBegan(interactor, transitionContext: transitionContext)
        if (self.isAllowsAppearanceTransition) {
            belowViewController?.beginAppearanceTransition(!isPresenting, animated: transitionContext.isAnimated)
        }
    }
    
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        guard let snapshotView = snapshotView,
              let aboveVC = aboveViewController,
              let belowVC = belowViewController else { return }
        
        let alpha: CGFloat = isPresenting ? 0 : 1
        let tintAdjustmentMode: UIView.TintAdjustmentMode = isPresenting ? .normal : .dimmed

        if (self.isAllowsAppearanceTransition) {
            belowVC.beginAppearanceTransition(!isPresenting, animated: context?.isAnimated == true)
        }
        
        animate(
            withDuration: 0.25,
            animations: {  [weak self] in
                aboveVC.view.alpha = alpha
                snapshotView.transform = .identity
                if self?.isAllowsDeactivating == true {
                    belowVC.view.tintAdjustmentMode = tintAdjustmentMode
                }
            },
            completion: { [weak self] in
                guard let self = self,
                      let context = self.context else { return }
                
                self.fromView?.isHidden = false
                self.toView?.isHidden = false
                
                if self.isPresenting {
                    aboveVC.view.removeFromSuperview()
                }
                self.removeSnapshotView()
                context.completeTransition(false)
                completion?()
            })
    }
    
    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        guard let snapshotView = snapshotView,
              let aboveVC = aboveViewController,
              let transform = transform else { return }
        
        let toScale = transform.scale.x
        let progress = min(1, max(0, (percent - 1) / (toScale - 1)))
        let alpha = isPresenting ? progress : (1 - progress)
        let scale = isPresenting ?
            min(toScale * 1.5, max(0.7, percent)) :
            min(1.5, max(toScale * 0.7, percent))
        
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.init(rawValue: 7), .allowUserInteraction],
            animations: {
                aboveVC.view.alpha = alpha
                snapshotView.transform = CGAffineTransform(scaleX: scale, y: scale)
            })
    }
    
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        guard let context = context,
              let snapshotView = snapshotView,
              let aboveVC = aboveViewController,
              let belowVC = belowViewController,
              let transform = transform,
              let toView = toView else { return }
        
        let alpha: CGFloat = isPresenting ? 1 : 0
        let tintAdjustmentMode: UIView.TintAdjustmentMode = isPresenting ? .dimmed : .normal
        let center = toView.superview?.convert(
            toView.center,
            to: context.containerView) ?? .zero

        if (self.isAllowsAppearanceTransition) {
            belowVC.beginAppearanceTransition(!isPresenting, animated: context.isAnimated == true)
        }
        
        animate({ [weak self] in
            aboveVC.view.alpha = alpha
            snapshotView.center = center
            snapshotView.transform = transform
            if self?.isAllowsDeactivating == true {
                belowVC.view.tintAdjustmentMode = tintAdjustmentMode
            }
        },
        completion: { [weak self] in
            guard let self = self else { return }
            
            self.fromView?.isHidden = false
            self.toView?.isHidden = false
            
            if self.isPresenting {
                if (self.isAllowsAppearanceTransition) {
                    belowVC.endAppearanceTransition()
                }
                context.completeTransition(!context.transitionWasCancelled)
                self.removeSnapshotView()
            } else {
                context.completeTransition(!context.transitionWasCancelled)
                self.removeSnapshotView()
                aboveVC.view.removeFromSuperview()

                if (self.isAllowsAppearanceTransition) {
                    belowVC.endAppearanceTransition()
                }
            }
            completion?()
        })
    }
    
    // MARK: Private
    
    private var transform: CGAffineTransform?
    private var fromView: UIView?
    private var snapshotView: UIView?
    private var toView: UIView?
    
    private func removeSnapshotView() {
        snapshotView?.removeFromSuperview()
        snapshotView = nil
        fromView = nil
        toView = nil
        transform = nil
    }
}
