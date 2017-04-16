//
//  AnimatedFadeTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import "AnimatedFadeTransitioning.h"

@implementation AnimatedFadeTransitioning

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    toViewController.view.alpha = 0;
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
            fromViewController.view.alpha = 0;
            toViewController.view.alpha = 1;
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        } completion:^(BOOL finished) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    toViewController.view.alpha = 0;
    toViewController.view.frame = fromViewController.view.bounds;
    
    [transitionContext.containerView addSubview:toViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
            toViewController.view.alpha = 1;
            fromViewController.view.alpha = 0;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        } completion:^(BOOL finished) {
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (![transitionContext transitionWasCancelled]) {
                fromViewController.view.hidden = YES;
            }
            
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    const CGFloat aboveViewAlpha = self.presenting ? 0 : 1;
    const CGFloat belowViewAlpha = self.presenting ? 1 : 0;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.alpha = aboveViewAlpha;
        self.belowViewController.view.alpha = belowViewAlpha;
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^(BOOL finished) {
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    self.aboveViewController.view.alpha = MAX(0, MIN(1, self.presenting ? bouncePercent : 1 - bouncePercent));
    self.belowViewController.view.alpha = MAX(0, MIN(1, self.presenting ? 1 - bouncePercent : bouncePercent));
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCompleted:interactor completion:completion];
    
    const CGFloat aboveViewAlpha = self.presenting ? 1 : 0;
    const CGFloat belowViewAlpha = self.presenting ? 0 : 1;
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.alpha = aboveViewAlpha;
        self.belowViewController.view.alpha = belowViewAlpha;
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        [context completeTransition:!context.transitionWasCancelled];
        completion();
    }];
}

@end
