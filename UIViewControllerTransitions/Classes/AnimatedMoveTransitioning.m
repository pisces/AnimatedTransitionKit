//
//  AnimatedMoveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 2015. 9. 24..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "AnimatedMoveTransitioning.h"
#import "AbstractUIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedMoveTransitioning

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    fromViewController.view.frame = CGRectMakeY(fromViewController.view.frame, 0);
    
    const CGFloat y = fromViewController.view.frame.origin.y;
    const CGFloat h = self.screenSize.height;
    const CGRect frame = CGRectMakeY(fromViewController.view.frame, y >= 0 ? h : -h);
    
    void (^animations)(void) = ^void (void) {
        if (!transitionContext.isInteractive) {
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            toViewController.view.alpha = 1;
            toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.frame = frame;
        }
    };
    void (^completion)(BOOL) = ^void (BOOL finished) {
        if (!transitionContext.isInteractive) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }
    };
    
    if (transitionContext.animated) {
        [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 options:7<<16 animations:animations completion:completion];
    } else {
        animations();
        completion(NO);
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    toViewController.view.frame = CGRectMakeY(fromViewController.view.frame, self.screenSize.height);
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 options:7<<16 animations:^{
        if (!transitionContext.isInteractive) {
            toViewController.view.frame = CGRectMakeY(toViewController.view.frame, 0);
            fromViewController.view.alpha = 0.5;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        }
    } completion:^(BOOL finished) {
        if (!transitionContext.isInteractive) {
            fromViewController.view.alpha = 1;
            fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (!transitionContext.transitionWasCancelled) {
                fromViewController.view.hidden = YES;
            }
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor {
    [super interactionBegan:interactor];
    
    const CGFloat y = self.presenting ? self.screenSize.height : 0;
    self.aboveViewController.view.frame = CGRectMakeY(self.aboveViewController.view.frame, y);
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    CGRect frame;
    if (interactor.direction == InteractiveTransitionDirectionVertical) {
        frame = CGRectMakeY(self.aboveViewController.view.frame, self.presenting ? self.screenSize.height : 0);
    } else {
        frame = CGRectMakeX(self.aboveViewController.view.frame, self.presenting ? self.screenSize.width : 0);
    }
    
    const CGFloat alpha = self.presenting ? 1 : 0.5;
    const CGFloat scale = self.presenting ? 1 : 0.94;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.frame = frame;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        if (self.presenting) {
            [self.aboveViewController viewDidDisappear:YES];
            [self.belowViewController viewDidAppear:YES];
        } else {
            [self.belowViewController viewDidDisappear:YES];
            [self.aboveViewController viewDidAppear:YES];
        }
        
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
    [super interactionCompleted:interactor completion:completion];
    
    CGRect frame;
    if (interactor.direction == InteractiveTransitionDirectionVertical) {
        frame = CGRectMakeY(self.aboveViewController.view.frame, self.presenting ? 0 : self.screenSize.height);
    } else {
        frame = CGRectMakeX(self.aboveViewController.view.frame, self.presenting ? 0 : self.screenSize.width);
    }
    
    const CGFloat alpha = self.presenting ? 0.5 : 1;
    const CGFloat scale = self.presenting ? 0.94 : 1;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.frame = frame;
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        if (self.presenting) {
            [self.belowViewController viewDidDisappear:YES];
            [self.aboveViewController viewDidAppear:YES];
        } else {
            [self.aboveViewController viewDidDisappear:YES];
            [self.belowViewController viewDidAppear:YES];
        }
        
        completion();
    }];
    
    [context completeTransition:!context.transitionWasCancelled];
}

@end
