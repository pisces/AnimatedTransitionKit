//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2020, Steve Kim
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
//  AbstractUIViewControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//

#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"
#import "PanningInteractiveTransition.h"
#import <objc/runtime.h>

@interface UIViewControllerTransition () <UIGestureRecognizerDelegate>
@end

@implementation UIViewControllerTransition
@synthesize currentInteractor = _currentInteractor;
@synthesize transitioning = _transitioning;

#pragma mark - Overridden: AbstractTransition

- (BOOL)isAppearingWithInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    return interactor.isVertical ? direction == PanningDirectionUp : direction == PanningDirectionLeft;
}

- (BOOL)isValidWithInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    if (interactor.isVertical) {
        return interactor.isAppearing ? direction == PanningDirectionUp : direction == PanningDirectionDown;
    }
    return interactor.isAppearing ? direction == PanningDirectionLeft : direction == PanningDirectionRight;
}

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    [super setAllowsInteraction:allowsInteraction];
    
    _dismissionInteractor.gestureRecognizer.enabled = allowsInteraction;
    _presentingInteractor.gestureRecognizer.enabled = allowsInteraction;
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController]) {
        return;
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self.dismissionInteractor attach:_viewController presentViewController:nil];
}

- (void)initProperties {
    [super initProperties];
    
    _durationForDismission = _durationForPresenting = 0.15;
    _animationOptionsForDismission = _animationOptionsForPresenting = 7<<16;
    _dismissionInteractor = [PanningInteractiveTransition new];
    _presentingInteractor = [PanningInteractiveTransition new];
}

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _currentInteractor = self.dismissionInteractor;
    _transitioning = [self transitioningForDismissedController:dismissed];
    _transitioning.animationOptions = _animationOptionsForDismission;
    _transitioning.duration = _durationForDismission;
    return _transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _currentInteractor = self.presentingInteractor;
    _transitioning = [self transitioningForForPresentedController:presented presentingController:presenting sourceController:source];
    ((AnimatedTransitioning *) _transitioning).presenting = YES;
    _transitioning.animationOptions = _animationOptionsForPresenting;
    _transitioning.duration = _durationForPresenting;
    return _transitioning;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.isInteracting) ? self.dismissionInteractor : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.isInteracting) ? self.presentingInteractor : nil;
}

#pragma mark - Protected methods

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return nil;
}

@end

static void *AssociatedKeyTransition = @"transition";

@implementation UIViewController (UIViewControllerTransitions)

- (void)setTransition:(UIViewControllerTransition *)transition {
    if ([transition isEqual:[self transition]])
        return;
    
    transition.viewController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, &AssociatedKeyTransition);
}

@end
