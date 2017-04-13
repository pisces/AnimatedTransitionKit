//
//  UIViewControllerFadeTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//
//

#import "UIViewControllerFadeTransition.h"
#import "AnimatedFadeTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerFadeTransition

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    AnimatedFadeTransitioning *transitioning = [AnimatedFadeTransitioning new];
    transitioning.duration = self.durationForDismission;
    return transitioning;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedFadeTransitioning *transitioning = [AnimatedFadeTransitioning new];
    transitioning.presenting = YES;
    transitioning.duration = self.durationForPresenting;
    return transitioning;
}

@end
