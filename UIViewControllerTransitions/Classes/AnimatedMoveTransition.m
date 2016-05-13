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

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [toViewController viewWillAppear:YES];
    
    if (toViewController.view.alpha <= 0)
        toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        toViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        const CGFloat y = CGRectGetMaxY(fromViewController.view.frame);
        const CGFloat h = CGRectGetHeight(fromViewController.view.frame);
        
        fromViewController.view.frame = CGRectMakeY(fromViewController.view.frame, y >= 0 ? h : -h);
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = YES;
        toViewController.view.window.backgroundColor = [UIColor whiteColor];
        
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    fromViewController.view.userInteractionEnabled = NO;
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    toViewController.view.frame = CGRectMake(0, fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        toViewController.view.frame = CGRectMakeY(toViewController.view.frame, 0);
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:YES];
        
        fromViewController.view.hidden = YES;
        fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

@end