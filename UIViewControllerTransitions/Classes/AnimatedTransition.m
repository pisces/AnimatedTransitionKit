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
    return _duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    if (self.presenting) {
        [self animateTransitionForPresenting:transitionContext];
    } else {
        [self animateTransitionForDismission:transitionContext];
    }
}

#pragma mark - Public methods

- (UIWindow *)statusBarWindow {
    return [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
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
