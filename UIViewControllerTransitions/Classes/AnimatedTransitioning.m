//
//  AnimatedTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//

#import "AnimatedTransitioning.h"
#import "AbstractUIViewControllerTransition.h"

@implementation AnimatedTransitioning

#pragma mark - Properties

- (UIViewController *)aboveViewController {
    return _presenting ? toViewController : fromViewController;
}

- (UIViewController *)belowViewController {
    return _presenting ? fromViewController : toViewController;
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].bounds.size;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    fromViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.modalPresentationCapturesStatusBarAppearance = YES;
    
    if (_presenting) {
        [self animateTransitionForPresenting:transitionContext];
    } else {
        [self animateTransitionForDismission:transitionContext];
    }
}

#pragma mark - Public methods

- (NSTimeInterval)currentDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return transitionContext.isInteractive ? 0 : [self transitionDuration:transitionContext];
}

- (void)interactionBegan:(UIPercentDrivenInteractiveTransition * _Nonnull)interactor {
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (void)interactionChanged:(UIPercentDrivenInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    bouncePercent = percent * (self.screenSize.height / self.aboveViewController.transition.bounceHeight);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

#pragma mark - Protected methods

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    context = transitionContext;
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    context = transitionContext;
}

@end
