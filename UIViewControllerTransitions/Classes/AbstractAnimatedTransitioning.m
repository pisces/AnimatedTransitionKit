//
//  AbstractAnimatedTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "AbstractAnimatedTransitioning.h"

@implementation AbstractAnimatedTransitioning

#pragma mark - UIViewControllerAnimatedTransitioning protocol

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _duration;
}

- (void)animationEnded:(BOOL)transitionCompleted {
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    _context = transitionContext;
    _fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
}

#pragma mark - Properties

- (CGFloat)completionBounds {
    return 60 * self.heightRatio;
}

- (CGFloat)heightRatio {
    return UIScreen.mainScreen.bounds.size.height/667;
}

- (CGFloat)widthRatio {
    return UIScreen.mainScreen.bounds.size.width/375;
}

- (UIViewController *)aboveViewController {
    return nil;
}

- (UIViewController *)belowViewController {
    return nil;
}

#pragma mark - Public methods

- (void)clear {
    _fromViewController.view.alpha = 1;
    _fromViewController.view.transform = CGAffineTransformTranslate(self.fromViewController.view.transform, 0, 0);
    _fromViewController.view.hidden = NO;
}

- (void)endAnimating {
    _animating = NO;
    _percentOfInteraction = 0;
    _percentOfBounds = 0;
}

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    _context = transitionContext;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    _percentOfInteraction = percent;
    
    [self updatePercentOfBounds];
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (BOOL)shouldComplete:(AbstractInteractiveTransition * _Nonnull)interactor {
    return self.percentOfBounds >= 1;
}

- (void)startAnimating {
    _animating = YES;
}

- (void)updatePercentOfBounds {
    _percentOfBounds = _percentOfInteraction * (UIScreen.mainScreen.bounds.size.height / _completionBounds);
}

@end
