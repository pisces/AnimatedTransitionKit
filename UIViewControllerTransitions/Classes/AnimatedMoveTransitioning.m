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
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedMoveTransitioning

#pragma mark - Properties

- (InteractiveTransitionDirection)direction {
    return self.presenting ? self.aboveViewController.transition.presentingInteractor.direction : self.aboveViewController.transition.dismissionInteractor.direction;
}

- (CGAffineTransform)cancelTransformTo {
    if (self.direction == InteractiveTransitionDirectionVertical) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? self.screenSize.height : 0);
    }
    return CGAffineTransformMakeTranslation(self.presenting ? self.screenSize.width : 0, 0);
}

- (CGAffineTransform)transformFrom {
    if (self.direction == InteractiveTransitionDirectionVertical) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? self.screenSize.height : 0);
    }
    return CGAffineTransformMakeTranslation(self.presenting ? self.screenSize.width : 0, 0);
}

- (CGAffineTransform)transformTo {
    const CGFloat value = self.direction == InteractiveTransitionDirectionVertical ? self.screenSize.height : self.screenSize.width;
    
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
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.transform = self.transformTo;
        } completion:^(BOOL finished) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [transitionContext.containerView addSubview:toViewController.view];
    toViewController.view.transform = self.transformFrom;
    
    if (!transitionContext.isInteractive) {
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
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    self.aboveViewController.view.transform = self.transformFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 1 : 0.5;
    const CGFloat scale = self.presenting ? 1 : 0.94;
    
    [UIView animateWithDuration:0.15 delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.cancelTransformTo;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    CGFloat alpha = self.presenting ? 1 - ((1 - 0.5) * bouncePercent) : 0.5 + ((1 - 0.5) * bouncePercent);
    CGFloat scale = self.presenting ? 1 - ((1 - 0.94) * bouncePercent) : 0.94 + ((1 - 0.94) * bouncePercent);
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
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

@end
