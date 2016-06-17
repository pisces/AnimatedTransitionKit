//
//  UIViewControllerFadeTransition.m
//  Pods
//
//  Created by Steve Kim on 6/18/16.
//
//

#import "UIViewControllerFadeTransition.h"
#import "AnimatedFadeTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerFadeTransition
// ================================================================================================
//  Overridden: AbstractUIViewControllerTransition
// ================================================================================================

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [AnimatedFadeTransition new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedFadeTransition *transition = [AnimatedFadeTransition new];
    transition.presenting = YES;
    return transition;
}

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
    self.viewController.view.window.backgroundColor = [UIColor blackColor];
}

- (void)animateTransitionCancelled:(UIPanGestureRecognizer *)gestureRecognizer {
    self.viewController.view.alpha = 1;
    self.viewController.presentingViewController.view.alpha = 0;
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.viewController;
        navigationController.navigationBar.alpha = 1;
    }
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.viewController.view.window];
    CGFloat y = originViewPoint.y + (p.y - originPoint.y);
    CGFloat alpha = MIN(0.5, 0.5 * ABS(y) / self.bounceHeight);
    
    self.viewController.presentingViewController.view.hidden = NO;
    self.viewController.presentingViewController.view.alpha = alpha;
    self.viewController.view.alpha = 1 - alpha;
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.viewController;
        navigationController.navigationBar.alpha = 1 - ABS(y)/self.bounceHeight;
    }
}

- (void)animateTransitionCancelCompleted {
    self.viewController.presentingViewController.view.hidden = YES;
}

@end
