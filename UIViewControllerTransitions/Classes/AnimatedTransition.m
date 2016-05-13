//
//  AnimatedTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import "AnimatedTransition.h"

@implementation AnimatedTransition

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting) {
        [self animateTransitionForPresenting:transitionContext];
    } else {
        [self animateTransitionForDismission:transitionContext];
    }
}

// ================================================================================================
//  Protected
// ================================================================================================

#pragma mark - Protected methods

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
}

@end
