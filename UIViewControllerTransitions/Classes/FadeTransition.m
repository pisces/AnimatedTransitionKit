//
//  FadeTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerFadeTransition to FadeTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring extract methods
//
//

#import "FadeTransition.h"
#import "FadeTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation FadeTransition

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    return [FadeTransitioning new];
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [FadeTransitioning new];
}

@end
