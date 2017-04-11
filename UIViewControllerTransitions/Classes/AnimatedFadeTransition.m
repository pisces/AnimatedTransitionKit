//
//  AnimatedFadeTransition.m
//  Pods
//
//  Created by Steve Kim on 6/18/16.
//
//

#import "AnimatedFadeTransition.h"

@implementation AnimatedFadeTransition

// ================================================================================================
//  Overridden: AnimatedTransition
// ================================================================================================

#pragma mark - Overridden: AnimatedTransition

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = toViewController.view.userInteractionEnabled;
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    [toViewController viewWillAppear:YES];
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = userInteractionEnabled;
        toViewController.view.window.backgroundColor = backgroundColor;
        
        [fromViewController.view removeFromSuperview];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = fromViewController.view.userInteractionEnabled;
    
    fromViewController.view.userInteractionEnabled = NO;
    
    toViewController.view.frame = CGRectMake(0, fromViewController.view.bounds.size.height, fromViewController.view.bounds.size.width, fromViewController.view.bounds.size.height);
    
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.alpha = 0;
    toViewController.view.frame = fromViewController.view.bounds;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        toViewController.view.alpha = 1;
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        fromViewController.view.userInteractionEnabled = userInteractionEnabled;
        
        if (![transitionContext transitionWasCancelled]) {
            fromViewController.view.hidden = YES;
        }
    }];
}

@end
