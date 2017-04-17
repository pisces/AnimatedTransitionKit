//
//  AnimatedTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedTransitioning.h"
#import "AbstractUIViewControllerTransition.h"

@implementation AnimatedTransitioning

#pragma mark - Con(De)structor

- (void)dealloc {
}

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
    context = transitionContext;
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

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    context = transitionContext;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    _bouncePercent = percent * (self.screenSize.height / self.aboveViewController.transition.bounceHeight);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

#pragma mark - Protected methods

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
}

@end
