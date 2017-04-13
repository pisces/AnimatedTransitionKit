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
    [self updateControllers];
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [self updateControllers];
}

- (void)interactionChanged:(UIPercentDrivenInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [self updateControllers];
    
    bouncePercent = percent * (self.screenSize.height / _aboveViewController.transition.bounceHeight);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [self updateControllers];
}

#pragma mark - Protected methods

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    context = transitionContext;
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    context = transitionContext;
}

#pragma mark - Private methods

- (void)updateControllers {
    _belowViewController = _presenting ? fromViewController : toViewController;
    _aboveViewController = _presenting ? toViewController : fromViewController;
}

@end
