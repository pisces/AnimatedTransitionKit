//
//  AnimatedNavigationTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//
//

#import "AnimatedNavigationTransitioning.h"

@implementation AnimatedNavigationTransitioning

#pragma mark - Overridden: AbstractAnimatedTransitioning

- (UIViewController *)aboveViewController {
    return _push ? self.toViewController : self.fromViewController;
}

- (UIViewController *)belowViewController {
    return _push ? self.fromViewController : self.toViewController;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransition:transitionContext];
    
    if (_push) {
        [self animateTransitionForPush:transitionContext];
    } else {
        [self animateTransitionForPop:transitionContext];
    }
}

#pragma mark - Protected methods

- (void)animateTransitionForPop:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)animateTransitionForPush:(id<UIViewControllerContextTransitioning>)transitionContext {
}

@end
