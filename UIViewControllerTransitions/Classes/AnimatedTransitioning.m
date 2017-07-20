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

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

- (void)animationEnded:(BOOL)transitionCompleted {
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

- (void)dismiss {
    fromViewController.view.alpha = 1;
    fromViewController.view.transform = CGAffineTransformTranslate(fromViewController.view.transform, 0, 0);
    fromViewController.view.hidden = NO;
    
    [fromViewController beginAppearanceTransition:YES animated:NO];
    [toViewController.view removeFromSuperview];
    [fromViewController endAppearanceTransition];
}

- (void)endAnimating {
    _animating = NO;
}

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    context = transitionContext;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    _bouncePercent = percent * (self.aboveViewController.view.bounds.size.height / self.aboveViewController.transition.bounceHeight);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (BOOL)shouldComplete:(AbstractInteractiveTransition * _Nonnull)interactor {
    return YES;
}

- (void)startAnimating {
    _animating = YES;
}

#pragma mark - Protected methods

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
}

@end
