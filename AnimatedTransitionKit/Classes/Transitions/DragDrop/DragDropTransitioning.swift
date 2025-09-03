//
//  DragDropTransitioning.swift
//  Pods
//
//  Created by Minwoo on 9/3/25.
//

import Foundation

public final class DragDropTransitioningSource {
    var image: (() -> UIImage)?
    var from: (() -> CGRect)?
    var to: (() -> CGRect)?
    var rotation: (() -> CGFloat)?
    var completion: (() -> Void)?

    func clear() {
        from = nil
        to = nil
        completion = nil
    }

    public static func image(
        _ image: @escaping () -> UIImage,
        from: @escaping () -> CGRect,
        to: @escaping () -> CGRect,
        rotation: (() -> CGFloat)? = nil,
        completion: (() -> Void)? = nil
    ) -> DragDropTransitioningSource {
        let source = DragDropTransitioningSource()
        source.image = image
        source.from = from
        source.to = to
        source.rotation = rotation
        source.completion = completion
        return source
    }
}

final class DragDropTransitioning: AnimatedTransitioning {
    var source: DragDropTransitioningSource?
    var imageViewContentMode: UIView.ContentMode = .scaleAspectFill
    
    private var beginViewPoint: CGPoint = .zero
    private var sourceImageView: UIMaskedImageView?

    private var angle: CGFloat {
        guard let rotation = source?.rotation?() else { return 0 }
        return rotation != 0 ? rotation * .pi / 180 : 0
    }
    
    // MARK: Private methods
    func clearSourceImageView() {
        sourceImageView?.removeFromSuperview()
        sourceImageView = nil
    }

    func completeSource() {
        source?.completion?()
        clearSourceImageView()
    }
    
    private func createImageView() -> UIMaskedImageView {
        let imageView = UIMaskedImageView(frame: source?.from?() ?? .zero)
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = imageViewContentMode
        imageView.image = source?.image?()
        imageView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return imageView
    }
    
    private func animateDismission() {
        aboveViewController?.view.alpha = 0
        if isAllowsDeactivating {
            belowViewController?.view.transform = .identity
            belowViewController?.view.tintAdjustmentMode = .normal
        }
        sourceImageView?.layer.transform = CATransform3DMakeRotation(angle, 0, 0, 1)
        sourceImageView?.frame = source?.to?() ?? .zero
    }
    
    private func cancel(_ block: (() -> Void)?) {
        if isPresenting {
            aboveViewController?.view.removeFromSuperview()
        } else {
            belowViewController?.view.isHidden = true
        }
        
        if isAllowsAppearanceTransition {
            belowViewController?.endAppearanceTransition()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.context?.completeTransition(!(self.context?.transitionWasCancelled ?? false))
            self.sourceImageView?.removeFromSuperview()
            self.sourceImageView = nil
            block?()
        }
    }
    
    private func completion(_ block: (() -> Void)?) {
        source?.completion?()
        context?.completeTransition(!(context?.transitionWasCancelled ?? false))
        block?()
        sourceImageView?.removeFromSuperview()
        source?.clear()
    }
    
    // MARK: Overrides
    override public func animateTransition(forDismission transitionContext: any UIViewControllerContextTransitioning) {
        if isAllowsDeactivating {
            toViewController?.view.isHidden = false
        }

        if sourceImageView == nil {
            sourceImageView = createImageView()
            transitionContext.containerView.addSubview(sourceImageView!)
        }

        guard !transitionContext.isInteractive else {
            return
        }

        animate({ [weak self] in
            self?.animateDismission()
        }, completion: { [weak self] in
            self?.completeSource()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            self?.fromViewController?.view.removeFromSuperview()
            
            if self?.isAllowsAppearanceTransition == true {
                self?.belowViewController?.endAppearanceTransition()
            }
        })
    }

    override func animateTransition(forPresenting transitionContext: any UIViewControllerContextTransitioning) {
        super.animateTransition(forPresenting: transitionContext)
        
        guard let toViewController else {
            return
        }
        
        sourceImageView = createImageView()
        toViewController.view.alpha = 0
        transitionContext.containerView.addSubview(toViewController.view)
        transitionContext.containerView.addSubview(sourceImageView!)
        
        if transitionContext.isInteractive {
            return
        }
        
        animate({ [weak self] in
            guard let self else {
                return
            }
            
            toViewController.view.alpha = 1
            
            if isAllowsDeactivating {
                fromViewController?.view.tintAdjustmentMode = .dimmed
                fromViewController?.view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
            }
            
            sourceImageView?.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1)
            sourceImageView?.frame = self.source?.to?() ?? .zero
        }, completion: { [weak self] in
            guard let self else {
                return
            }
            
            if isAllowsDeactivating {
                fromViewController?.view.alpha = 1
                fromViewController?.view.transform = .identity
                
                if !transitionContext.transitionWasCancelled {
                    fromViewController?.view.isHidden = true
                }
            }
            
            if isAllowsAppearanceTransition {
                fromViewController?.endAppearanceTransition()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            completeSource()
        })
    }
    
    override func interactionBegan(_ interactor: AbstractInteractiveTransition, transitionContext: UIViewControllerContextTransitioning) {
        super.interactionBegan(interactor, transitionContext: transitionContext)
        beginViewPoint = interactor.currentViewController.view.frame.origin
        
        guard !isPresenting else {
            return
        }
        
        if isAllowsAppearanceTransition {
            belowViewController?.beginAppearanceTransition(!isPresenting, animated: transitionContext.isAnimated)
        }
        
        aboveViewController?.view.isHidden = false
    }
    
    override func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)?) {
        super.interactionCancelled(interactor, completion: completion)
        beginViewPoint = .zero
        
        guard !isPresenting else {
            return
        }
        
        animate(withDuration: 0.25, animations: { [weak self] in
            guard let self else {
                return
            }
            
            aboveViewController?.view.alpha = 1
            
            if isAllowsDeactivating {
                belowViewController?.view.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
                belowViewController?.view.tintAdjustmentMode = .dimmed
            }
            
            sourceImageView?.transform = .identity
            sourceImageView?.frame = source?.from?() ?? .zero
        }, completion: { [weak self] in
            guard let self else {
                return
            }
            
            if isPresenting {
                aboveViewController?.view.removeFromSuperview()
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
            clearSourceImageView()
        })
    }

    override func interactionChanged(_ interactor: AbstractInteractiveTransition, percent: CGFloat) {
        super.interactionChanged(interactor, percent: percent)
        
        guard !isPresenting else {
            return
        }
        
        let y = beginViewPoint.y + interactor.translation.y
        let imageScale = min(1, max(0.5, 1 - abs(y) / (aboveViewController?.view.bounds.height ?? 1)))
        
        sourceImageView?.transform = CGAffineTransform(scaleX: imageScale, y: imageScale)
            .translatedBy(x: interactor.translation.x, y: interactor.translation.y)
        
        if isAllowsDeactivating {
            let alpha = 1 - percentOfCompletion
            let scale = min(1, 0.94 + ((1 - 0.94) * percentOfCompletion))
            belowViewController?.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            aboveViewController?.view.alpha = alpha
        }
    }
    
    override func interactionCompleted(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)?) {
        super.interactionCompleted(interactor, completion: completion)
        
        guard let context else {
            return
        }
        
        beginViewPoint = .zero
        
        guard !isPresenting else {
            return
        }
        
        animate({ [weak self] in
            self?.animateDismission()
        }, completion: { [weak self] in
            completion?()
            self?.completeSource()
            self?.aboveViewController?.view.removeFromSuperview()
            self?.context?.completeTransition(!context.transitionWasCancelled)
            
            if self?.isAllowsAppearanceTransition == true {
                self?.belowViewController?.endAppearanceTransition()
            }
        })
    }
}
