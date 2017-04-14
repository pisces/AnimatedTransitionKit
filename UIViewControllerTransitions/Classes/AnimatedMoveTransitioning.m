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

- (CGRect)cancelFrameTo {
    if (self.direction == InteractiveTransitionDirectionVertical) {
        return CGRectMake(0, self.presenting ? self.screenSize.height : 0, self.screenSize.width, self.screenSize.height);
    }
    return CGRectMake(self.presenting ? self.screenSize.width : 0, 0, self.screenSize.width, self.screenSize.height);
}

- (CGRect)frameFrom {
    if (self.direction == InteractiveTransitionDirectionVertical) {
        return CGRectMake(0, self.presenting ? self.screenSize.height : 0, self.screenSize.width, self.screenSize.height);
    }
    return CGRectMake(self.presenting ? self.screenSize.width : 0, 0, self.screenSize.width, self.screenSize.height);
}

- (CGRect)frameTo {
    const CGFloat value = self.direction == InteractiveTransitionDirectionVertical ? self.screenSize.height : self.screenSize.width;
    
    if (self.direction == InteractiveTransitionDirectionVertical) {
        const CGFloat y = self.aboveViewController.view.frame.origin.y;
        return CGRectMakeY(self.aboveViewController.view.frame, self.presenting ? 0 : y >= 0 ? value : -value);
    }
    const CGFloat x = self.aboveViewController.view.frame.origin.x;
    return CGRectMakeX(self.aboveViewController.view.frame, self.presenting ? 0 : x >= 0 ? value : -value);
}

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    fromViewController.view.frame = self.frameFrom;
    
    [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 options:7<<16 animations:^{
        if (!transitionContext.isInteractive) {
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.frame = self.frameTo;
        }
    } completion:^(BOOL finished) {
        if (!transitionContext.isInteractive) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
        }
    }];
    
    if (!transitionContext.isInteractive) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    toViewController.view.frame = self.frameFrom;
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 options:7<<16 animations:^{
        if (!transitionContext.isInteractive) {
            toViewController.view.frame = self.frameTo;
            fromViewController.view.alpha = 0.5;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        }
    } completion:^(BOOL finished) {
        if (!transitionContext.isInteractive && !transitionContext.transitionWasCancelled) {
            fromViewController.view.alpha = 1;
            fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor {
    self.aboveViewController.view.frame = self.frameFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 1 : 0.5;
    const CGFloat scale = self.presenting ? 1 : 0.94;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.frame = self.cancelFrameTo;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        [toViewController viewDidDisappear:YES];
        [fromViewController viewDidAppear:YES];
        
        completion();
    }];
    
    [context completeTransition:!context.transitionWasCancelled];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    CGFloat alpha = self.presenting ? 1 - ((1 - 0.5) * bouncePercent) : 0.5 + ((1 - 0.5) * bouncePercent);
    CGFloat scale = self.presenting ? 1 - ((1 - 0.94) * bouncePercent) : 0.94 + ((1 - 0.94) * bouncePercent);
    alpha = MAX(0.5, MIN(1, alpha));
    scale = MAX(0.94, MIN(1, scale));
    
    if (interactor.direction == InteractiveTransitionDirectionVertical) {
        const CGFloat y = interactor.beginViewPoint.y + (interactor.point.y - interactor.beginPoint.y);
        self.aboveViewController.view.frame = CGRectMakeY(self.aboveViewController.view.frame, y);
    } else {
        const CGFloat x = interactor.beginViewPoint.x + (interactor.point.x - interactor.beginPoint.x);
        self.aboveViewController.view.frame = CGRectMakeX(self.aboveViewController.view.frame, x);
    }
    
    self.belowViewController.view.alpha = alpha;
    self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 0.5 : 1;
    const CGFloat scale = self.presenting ? 0.94 : 1;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.frame = self.frameTo;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        
        completion();
    }];
    
    [context completeTransition:!context.transitionWasCancelled];
}

@end
