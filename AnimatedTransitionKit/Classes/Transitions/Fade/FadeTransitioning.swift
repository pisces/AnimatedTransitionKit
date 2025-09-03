//
//  FadeTransitioning.swift
//  Pods
//
//  Created by Minwoo on 9/3/25.
//

import Foundation

final class FadeTransitioning: AnimatedTransitioning {
    override func animateTransition(forDismission transitionContext: UIViewControllerContextTransitioning) {
        if isAllowsDeactivating {
            toViewController?.view.alpha = 0
        }
        toViewController?.view.isHidden = false
        
        guard !transitionContext.isInteractive else {
            return
        }
        
        animate { [weak self] in
            self?.fromViewController?.view.alpha = 0
            
            if self?.isAllowsDeactivating == true {
                self?.toViewController?.view.alpha = 1
                self?.toViewController?.view.tintAdjustmentMode = .normal
            }
        } completion: { [weak self] in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self?.fromViewController?.view.removeFromSuperview()
            
            if self?.isAllowsAppearanceTransition == true {
                self?.toViewController?.endAppearanceTransition()
            }
        }
    }
    
    override func animateTransition(forPresenting transitionContext: any UIViewControllerContextTransitioning) {
        super.animateTransition(forPresenting: transitionContext)
        
        guard let toViewController,
            !transitionContext.isInteractive else {
            return
        }
        
        toViewController.view.alpha = 0
        transitionContext.containerView.addSubview(toViewController.view)
        
        animate { [weak self] in
            self?.toViewController?.view.alpha = 1
            
            if self?.isAllowsDeactivating == true {
                self?.fromViewController?.view.alpha = 0
                self?.fromViewController?.view.tintAdjustmentMode = .dimmed
            }
        } completion: { [weak self] in
            if self?.isAllowsDeactivating == true && !(transitionContext.transitionWasCancelled) {
                self?.fromViewController?.view.isHidden = true
            }
            
            if self?.isAllowsAppearanceTransition == true {
                self?.fromViewController?.endAppearanceTransition()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    override func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: any UIViewControllerContextTransitioning) {
        super.interactionBegan(interactor, transitionContext: transitionContext)
        
        if isAllowsAppearanceTransition {
            belowViewController?.beginAppearanceTransition(!isPresenting, animated: transitionContext.isAnimated)
        }
    }
    
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        let aboveViewAlpha: CGFloat = isPresenting ? 0 : 1
        
        if isAllowsAppearanceTransition {
            belowViewController?.beginAppearanceTransition(isPresenting, animated: context?.isAnimated ?? false)
        }
        
        animate(withDuration: 0.25) { [weak self] in
            self?.aboveViewController?.view.alpha = aboveViewAlpha
            
            if self?.isAllowsDeactivating == true {
                let belowViewAlpha: CGFloat = self?.isPresenting == true ? 1 : 0
                self?.belowViewController?.view.alpha = belowViewAlpha
                self?.belowViewController?.view.tintAdjustmentMode = self?.isPresenting == true ? .normal : .dimmed
            }
        } completion: { [weak self] in
            if self?.isPresenting == true {
                self?.aboveViewController?.view.removeFromSuperview()
                self?.context?.completeTransition(false)
                
                if self?.isAllowsAppearanceTransition == true {
                    self?.belowViewController?.endAppearanceTransition()
                }
            } else {
                if self?.isAllowsDeactivating == true {
                    self?.belowViewController?.view.isHidden = true
                }
                if self?.isAllowsAppearanceTransition == true {
                    self?.belowViewController?.endAppearanceTransition()
                }
                self?.context?.completeTransition(false)
            }
            
            completion?()
        }
    }
    
    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        let restrictedPercent = min(1, max(0, percent))
        super.interactionChanged(interactor, percent: restrictedPercent)
        
        aboveViewController?.view.alpha = max(0, min(1, isPresenting ? restrictedPercent : 1 - restrictedPercent))
        
        if isAllowsDeactivating {
            belowViewController?.view.alpha = max(0, min(1, isPresenting ? 1 - restrictedPercent : restrictedPercent))
        }
    }
    
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        guard let context = context else {
            return
        }
        
        let aboveViewAlpha: CGFloat = isPresenting ? 1 : 0
        
        animate { [weak self] in
            self?.aboveViewController?.view.alpha = aboveViewAlpha
            
            if self?.isAllowsDeactivating == true {
                let belowViewAlpha: CGFloat = self?.isPresenting == true ? 0 : 1
                self?.belowViewController?.view.alpha = belowViewAlpha
                self?.belowViewController?.view.tintAdjustmentMode = self?.isPresenting == true ? .dimmed : .normal
            }
        } completion: { [weak self] in
            guard let self else {
                return
            }
            
            if isPresenting {
                if isAllowsDeactivating {
                    belowViewController?.view.isHidden = true
                }
                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
                
                completion?()
                context.completeTransition(!context.transitionWasCancelled)
            } else {
                aboveViewController?.view.removeFromSuperview()
                completion?()
                context.completeTransition(!context.transitionWasCancelled)
                
                if isAllowsAppearanceTransition {
                    belowViewController?.endAppearanceTransition()
                }
            }
        }
    }

    override func shouldTransition(_ interactor: AbstractInteractiveTransition) -> Bool {
        interactor.translation.y - interactor.translationOffset >= 0
    }
    
    override func updateTranslationOffset(_ interactor: AbstractInteractiveTransition) {
        guard let panningInteractor = interactor as? PanningInteractiveTransition,
            let scrollView = panningInteractor.drivingScrollView else {
            return
        }
        
        panningInteractor.translationOffset = scrollView.contentOffset.y + scrollView.extAdjustedContentInset.top
    }
}
