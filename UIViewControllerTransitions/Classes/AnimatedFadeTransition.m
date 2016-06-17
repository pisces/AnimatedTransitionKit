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

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [toViewController viewWillAppear:YES];
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = YES;
        toViewController.view.window.backgroundColor = [UIColor whiteColor];
        
        [fromViewController.view removeFromSuperview];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:YES];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
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
        [transitionContext completeTransition:YES];
        
        fromViewController.view.hidden = YES;
    }];
}

@end
