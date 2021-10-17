//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2021, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

#import "FadeTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation FadeTransitioning

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIColor *backgroundColor = self.toViewController.view.window.backgroundColor;
    
    self.toViewController.view.alpha = 0;
    self.toViewController.view.hidden = NO;
    self.toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        self.fromViewController.view.alpha = 0;
        self.toViewController.view.alpha = 1;
        self.toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } completion:^{
        self.toViewController.view.window.backgroundColor = backgroundColor;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [self.fromViewController.view removeFromSuperview];
        [self.belowViewController endAppearanceTransition];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIColor *backgroundColor = self.toViewController.view.window.backgroundColor;
    
    self.toViewController.view.alpha = 0;
    self.toViewController.view.frame = self.fromViewController.view.bounds;
    
    [transitionContext.containerView addSubview:self.toViewController.view];
    
    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        self.toViewController.view.alpha = 1;
        self.fromViewController.view.alpha = 0;
        self.fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    } completion:^{
        self.fromViewController.view.window.backgroundColor = backgroundColor;
        
        if (![transitionContext transitionWasCancelled]) {
            self.fromViewController.view.hidden = YES;
        }
        
        [self.belowViewController endAppearanceTransition];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    [self.belowViewController beginAppearanceTransition:!self.presenting animated:transitionContext.isAnimated];
    
    self.aboveViewController.view.hidden = NO;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat aboveViewAlpha = self.presenting ? 0 : 1;
    const CGFloat belowViewAlpha = self.presenting ? 1 : 0;
    
    [self animateWithDuration:0.25 animations:^{
        self.aboveViewController.view.alpha = aboveViewAlpha;
        self.belowViewController.view.alpha = belowViewAlpha;
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
    } completion:^{
        if (self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        } else {
            self.belowViewController.view.hidden = YES;
        }
        
        [self.context completeTransition:NO];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:fmin(1, fmax(0, percent))];
    
    CGFloat caculated = fmin(1, fmax(0, percent));
    self.aboveViewController.view.alpha = MAX(0, MIN(1, self.presenting ? caculated : 1 - caculated));
    self.belowViewController.view.alpha = MAX(0, MIN(1, self.presenting ? 1 - caculated : caculated));
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat aboveViewAlpha = self.presenting ? 1 : 0;
    const CGFloat belowViewAlpha = self.presenting ? 0 : 1;
    
    [self animate:^{
        self.aboveViewController.view.alpha = aboveViewAlpha;
        self.belowViewController.view.alpha = belowViewAlpha;
        self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
    } completion:^{
        if (self.presenting) {
            self.belowViewController.view.hidden = YES;
            [self.belowViewController endAppearanceTransition];
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        } else {
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
            [self.aboveViewController.view removeFromSuperview];
            [self.belowViewController endAppearanceTransition];
        }
    }];
}

@end
