//
//  AnimatedMoveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 2015. 9. 24..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedMoveTransitioning.h"
#import "AbstractUIViewControllerTransition.h"
#import "PanningInteractiveTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedMoveTransitioning
{
    PanningDirection panningDirection;
}

#pragma mark - Properties

- (InteractiveTransitionDirection)direction {
    return self.presenting ? self.aboveViewController.transition.presentingInteractor.direction : self.aboveViewController.transition.dismissionInteractor.direction;
}

- (CGAffineTransform)transformFrom {
    CGSize size = self.presenting ? fromViewController.view.frame.size : toViewController.view.frame.size;
    
    if (self.direction == InteractiveTransitionDirectionVertical) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? size.height * (panningDirection == PanningDirectionDown ? -1 : 1) : 0);
    }
    return CGAffineTransformMakeTranslation(self.presenting ? size.height * (panningDirection == PanningDirectionRight ? -1 : 1) : 0, 0);
}

- (CGAffineTransform)transformTo {
    CGSize size = self.presenting ? fromViewController.view.frame.size : toViewController.view.frame.size;
    const CGFloat value = self.direction == InteractiveTransitionDirectionVertical ? size.height : size.width;
    
    if (self.direction == InteractiveTransitionDirectionVertical) {
        const CGFloat y = self.aboveViewController.view.transform.ty;
        return CGAffineTransformMakeTranslation(0, self.presenting ? 0 : y >= 0 ? value : -value);
    }
    const CGFloat x = self.aboveViewController.view.transform.tx;
    return CGAffineTransformMakeTranslation(self.presenting ? 0 : x >= 0 ? value : -value, 0);
}

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    fromViewController.view.transform = self.transformFrom;
    
    [toViewController viewWillAppear:YES];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.transform = self.transformTo;
        } completion:^(BOOL finished) {
            toViewController.view.window.backgroundColor = backgroundColor;
            [fromViewController.view removeFromSuperview];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    toViewController.view.transform = self.transformFrom;
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    
    if (!transitionContext.isInteractive) {
        toViewController.view.hidden = NO;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
            toViewController.view.transform = self.transformTo;
            fromViewController.view.alpha = 0.5;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        } completion:^(BOOL finished) {
            fromViewController.view.alpha = 1;
            fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (!transitionContext.transitionWasCancelled) {
                fromViewController.view.hidden = YES;
            }
            
            [fromViewController viewDidDisappear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    panningDirection = ((UIPanGestureRecognizer *) interactor.gestureRecognizer).panningDirection;
    self.aboveViewController.view.transform = self.transformFrom;
    self.aboveViewController.view.hidden = NO;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {const CGFloat alpha = self.presenting ? 1 : 0.5;
    const CGFloat scale = self.presenting ? 1 : 0.94;
    
    [UIView animateWithDuration:0.15 delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.transformFrom;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        if (self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        }
        
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    CGFloat alpha = self.presenting ? 1 - ((1 - 0.5) * self.bouncePercent) : 0.5 + ((1 - 0.5) * self.bouncePercent);
    CGFloat scale = self.presenting ? 1 - ((1 - 0.94) * self.bouncePercent) : 0.94 + ((1 - 0.94) * self.bouncePercent);
    alpha = MAX(0.5, MIN(1, alpha));
    scale = MAX(0.94, MIN(1, scale));
    
    if (interactor.direction == InteractiveTransitionDirectionVertical) {
        const CGFloat y = self.transformFrom.ty + (interactor.point.y - interactor.beginPoint.y);
        self.aboveViewController.view.transform = CGAffineTransformMakeTranslation(0, y);
    } else {
        const CGFloat x = self.transformFrom.tx + (interactor.point.x - interactor.beginPoint.x);
        self.aboveViewController.view.transform = CGAffineTransformMakeTranslation(x, 0);
    }
    
    self.belowViewController.view.alpha = alpha;
    self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 0.5 : 1;
    const CGFloat scale = self.presenting ? 0.94 : 1;
    
    [UIView animateWithDuration:0.15 delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.transformTo;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        if (self.presenting) {
            [self.belowViewController viewDidDisappear:YES];
        } else {
            [self.aboveViewController.view removeFromSuperview];
            [self.belowViewController viewDidAppear:YES];
        }
        
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

@end
