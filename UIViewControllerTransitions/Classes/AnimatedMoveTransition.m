//
//  AnimatedMoveTransition.m
//  PSUIKit
//
//  Created by pisces on 2015. 9. 24..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "AnimatedMoveTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedMoveTransition

// ================================================================================================
//  Overridden: AnimatedTransition
// ================================================================================================

#pragma mark - Overridden: AnimatedTransition

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = toViewController.view.userInteractionEnabled;
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    [toViewController viewWillAppear:YES];
    
    if (toViewController.view.alpha <= 0) {
        toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    }
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    const CGFloat y = fromViewController.view.frame.origin.y;
    const CGFloat h = CGRectGetHeight(fromViewController.view.frame);
    const CGRect toFrame = CGRectMakeY(fromViewController.view.frame, y >= 0 ? h : -h);
    
    void (^animations)(void) = ^void (void) {
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        toViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
//        self.statusBarWindow.frame = CGRectMakeY(self.statusBarWindow.frame, toFrame.origin.y);
        fromViewController.view.frame = toFrame;
    };
    void (^completion)(BOOL) = ^void (BOOL finished) {
//        self.statusBarWindow.frame = CGRectMakeY(self.statusBarWindow.frame, 0);
        toViewController.view.userInteractionEnabled = userInteractionEnabled;
        toViewController.view.window.backgroundColor = backgroundColor;
        
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    };
    
    if (transitionContext.animated) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:animations completion:completion];
    } else {
        animations();
        completion(NO);
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = fromViewController.view.userInteractionEnabled;
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    fromViewController.view.userInteractionEnabled = NO;
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
//    self.statusBarWindow.frame = CGRectMakeY(self.statusBarWindow.frame, fromViewController.view.bounds.size.height);
    toViewController.view.frame = CGRectMake(0, fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
//        self.statusBarWindow.frame = CGRectMakeY(self.statusBarWindow.frame, 0);
        toViewController.view.frame = CGRectMakeY(toViewController.view.frame, 0);
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        fromViewController.view.userInteractionEnabled = userInteractionEnabled;
        fromViewController.view.window.backgroundColor = backgroundColor;
        
        if (![transitionContext transitionWasCancelled]) {
            fromViewController.view.hidden = YES;
        }
    }];
}

@end
