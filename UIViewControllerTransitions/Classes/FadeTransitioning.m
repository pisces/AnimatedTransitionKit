//
//  FadeTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedFadeTransitioning to FadeTransitioning
//
//

#import "FadeTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation FadeTransitioning

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = self.toViewController.view.window.backgroundColor;
    
    self.toViewController.view.alpha = 0;
    self.toViewController.view.hidden = NO;
    self.toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [self.toViewController beginAppearanceTransition:YES animated:YES];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.alpha = 0;
            self.toViewController.view.alpha = 1;
            self.toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
        } completion:^(BOOL finished) {
            self.toViewController.view.window.backgroundColor = backgroundColor;
            
            [self.fromViewController.view removeFromSuperview];
            [self.toViewController endAppearanceTransition];
            
            dispatch_after_sec(0.01, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = self.toViewController.view.window.backgroundColor;
    
    self.toViewController.view.alpha = 0;
    self.toViewController.view.frame = self.fromViewController.view.bounds;
    
    [transitionContext.containerView addSubview:self.toViewController.view];
    [self.fromViewController beginAppearanceTransition:NO animated:YES];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.toViewController.view.alpha = 1;
            self.fromViewController.view.alpha = 0;
            self.fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        } completion:^(BOOL finished) {
            self.fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (![transitionContext transitionWasCancelled]) {
                self.fromViewController.view.hidden = YES;
            }
            
            [self.fromViewController endAppearanceTransition];
            
            dispatch_after_sec(0.01, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
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
        if (self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        }
        
        dispatch_after_sec(0.01, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:fmin(1, fmax(0, percent))];
    
    CGFloat _percent = fmin(1, fmax(0, percent));
    
    self.aboveViewController.view.alpha = MAX(0, MIN(1, self.presenting ? _percent : 1 - _percent));
    self.belowViewController.view.alpha = MAX(0, MIN(1, self.presenting ? 1 - _percent : _percent));
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCompleted:interactor completion:completion];
    
    const CGFloat aboveViewAlpha = self.presenting ? 1 : 0;
    const CGFloat belowViewAlpha = self.presenting ? 0 : 1;
    
    [UIView animateWithDuration:0.2 delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.alpha = aboveViewAlpha;
        self.belowViewController.view.alpha = belowViewAlpha;
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        if (!self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        }
        
        [self.belowViewController endAppearanceTransition];
        
        dispatch_after_sec(0.01, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

@end
