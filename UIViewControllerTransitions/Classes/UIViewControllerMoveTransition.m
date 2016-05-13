//
//  UIViewControllerMoveTransition.m
//  Pods
//
//  Created by Steve Kim on 5/13/16.
//
//

#import "UIViewControllerMoveTransition.h"
#import "AnimatedMoveTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerMoveTransition
{
    UIStatusBarStyle originStatusBarStyle;
}

// ================================================================================================
//  Overridden: AbstractUIViewControllerTransition
// ================================================================================================

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [AnimatedMoveTransition new];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedMoveTransition *transition = [AnimatedMoveTransition new];
    transition.presenting = YES;
    return transition;
}

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
    originStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.viewController.view.window.backgroundColor = [UIColor blackColor];
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
}

- (void)animateTransitionCancelled:(UIPanGestureRecognizer *)gestureRecognizer {
    self.viewController.view.frame = CGRectMakeY(self.viewController.view.frame, 0);
    self.viewController.presentingViewController.view.alpha = 0;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    
    const CGFloat y = CGRectGetMinY(self.viewController.view.frame);

    [UIApplication sharedApplication].statusBarStyle = y > [UIApplication sharedApplication].statusBarFrame.size.height ? UIStatusBarStyleLightContent : originStatusBarStyle;
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
    const CGPoint p = [gestureRecognizer locationInView:self.viewController.view.window];
    const CGFloat y = originViewPoint.y + (p.y - originPoint.y);
    const CGFloat alpha = MIN(0.5, 0.5 * ABS(y) / self.bounceHeight);
    const CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * ABS(y) / self.bounceHeight));
    
    self.viewController.view.frame = CGRectMakeY(self.viewController.view.frame, y);
    self.viewController.presentingViewController.view.hidden = NO;
    self.viewController.presentingViewController.view.alpha = alpha;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    
    [UIApplication sharedApplication].statusBarStyle = y > [UIApplication sharedApplication].statusBarFrame.size.height ? UIStatusBarStyleLightContent : originStatusBarStyle;
}

- (void)animateTransitionCancelCompleted {
    self.viewController.presentingViewController.view.hidden = YES;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
}

@end
