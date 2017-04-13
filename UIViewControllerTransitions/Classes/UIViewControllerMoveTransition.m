//
//  UIViewControllerMoveTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//
//

#import "UIViewControllerMoveTransition.h"
#import "AnimatedMoveTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerMoveTransition

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    AnimatedMoveTransitioning *transitioning = [AnimatedMoveTransitioning new];
    transitioning.duration = self.durationForDismission;
    return transitioning;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedMoveTransitioning *transitioning = [AnimatedMoveTransitioning new];
    transitioning.presenting = YES;
    transitioning.duration = self.durationForPresenting;
    return transitioning;
}

@end
