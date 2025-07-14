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
//  NavigationMoveTransitioning.m
//  AnimatedTransitionKit
//
//  Created by pisces on 13/08/2017.
//

#import "NavigationMoveTransitioning.h"
#import "PanningInteractiveTransition.h"
#import "AnimatedTransitionKitMacro.h"

const CGFloat unfocusedCompletionBounds = 50;

@implementation NavigationMoveTransitioning

#pragma mark - Overridden: AnimatedNavigationTransitioning

- (void)animateTransitionForPop:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.layer.transform = self.focusedTransformFrom;
    self.toViewController.view.layer.transform = self.unfocusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [self applyDropShadow:self.fromViewController.view.layer];
    [transitionContext.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        self.fromViewController.view.layer.transform = self.focusedTransformTo;
        self.toViewController.view.layer.transform = self.unfocusedTransformTo;
    } completion:^{
        self.fromViewController.view.hidden = YES;
        self.fromViewController.view.layer.transform = CATransform3DIdentity;
        self.toViewController.view.layer.transform = CATransform3DIdentity;
        [self clearDropShadow:self.fromViewController.view.layer];
        [self toggleIsPush];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)animateTransitionForPush:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.layer.transform = self.unfocusedTransformFrom;
    self.toViewController.view.layer.transform = self.focusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [self applyDropShadow:self.toViewController.view.layer];
    [transitionContext.containerView addSubview:self.toViewController.view];
    
    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        self.fromViewController.view.layer.transform = self.unfocusedTransformTo;
        self.toViewController.view.layer.transform = self.focusedTransformTo;
    } completion:^{
        self.fromViewController.view.hidden = YES;
        self.fromViewController.view.layer.transform = CATransform3DIdentity;
        self.toViewController.view.layer.transform = CATransform3DIdentity;
        [self clearDropShadow:self.toViewController.view.layer];
        [self toggleIsPush];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    self.aboveViewController.view.layer.transform = self.focusedTransformFrom;
    self.belowViewController.view.layer.transform = self.unfocusedTransformFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [self animateWithDuration:0.2 animations:^{
        self.aboveViewController.view.layer.transform = self.focusedTransformFrom;
        self.belowViewController.view.layer.transform = self.unfocusedTransformFrom;
    } completion:^{
        self.aboveViewController.view.layer.transform = CATransform3DIdentity;
        self.belowViewController.view.layer.transform = CATransform3DIdentity;
        self.belowViewController.view.hidden = !self.isPush;
        [self.context completeTransition:!self.context.transitionWasCancelled];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    const CGFloat x = CATransform3DGetAffineTransform(self.focusedTransformFrom).tx + (interactor.translation.x * 1.2);
    self.aboveViewController.view.layer.transform = CATransform3DMakeTranslation(MAX(0, x), 0, 1);
    self.belowViewController.view.layer.transform = self.unfocusedTransform;
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [self animate:^{
        self.aboveViewController.view.layer.transform = self.focusedTransformTo;
        self.belowViewController.view.layer.transform = self.unfocusedTransformTo;
    } completion:^{
        self.aboveViewController.view.layer.transform = CATransform3DIdentity;
        self.belowViewController.view.layer.transform = CATransform3DIdentity;
        self.belowViewController.view.hidden = self.isPush;
        [self.context completeTransition:!self.context.transitionWasCancelled];
        [self toggleIsPush];
        completion();
    }];
}

#pragma mark - Properties

- (CATransform3D)focusedTransformFrom {
    return CATransform3DMakeTranslation(self.isPush ? UIScreen.mainScreen.bounds.size.width : 0, 0, 1);
}

- (CATransform3D)focusedTransformTo {
    return CATransform3DMakeTranslation(self.isPush ? 0 : UIScreen.mainScreen.bounds.size.width, 0, 1);
}

- (CATransform3D)unfocusedTransform {
    CGFloat x = self.isPush ? -unfocusedCompletionBounds * self.percentOfInteraction : -(unfocusedCompletionBounds - (unfocusedCompletionBounds * self.percentOfInteraction));
    return CATransform3DMakeTranslation(MIN(0, MAX(-unfocusedCompletionBounds, x)), 0, 1);
}

- (CATransform3D)unfocusedTransformFrom {
    return CATransform3DMakeTranslation(self.isPush ? 0 : -unfocusedCompletionBounds, 0, 1);
}

- (CATransform3D)unfocusedTransformTo {
    return CATransform3DMakeTranslation(self.isPush ? -unfocusedCompletionBounds : 0, 0, 1);
}

#pragma mark - Private methods

- (void)applyDropShadow:(CALayer *)layer {
    layer.shouldRasterize = YES;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeMake(-1, -1);
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = 3;
    layer.shadowOpacity = 0.3;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)clearDropShadow:(CALayer *)layer {
    layer.masksToBounds = YES;
    layer.shouldRasterize = NO;
    layer.shadowOffset = CGSizeZero;
    layer.shadowRadius = 0;
    layer.shadowOpacity = 0;
}

- (void)toggleIsPush {
    self.push = !self.push;
}

@end

