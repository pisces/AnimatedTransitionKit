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

- (void)initProperties {
    [super initProperties];
    
    _appearenceInteractor = [PanningInteractiveTransition new];
    _disappearenceInteractor = [PanningInteractiveTransition new];
}

- (BOOL)isAppearing:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]] ||
        !interactor.isAppearing) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).startPanningDirection;
    return interactor.isVertical ? direction == PanningDirectionUp : direction == PanningDirectionLeft;
}

- (BOOL)isValid:(AbstractInteractiveTransition *)interactor {
    return interactor.isAppearing ? [self isAppearing:interactor] : YES;
}

- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    return interactor.isVertical ?
        (interactor.isAppearing ? direction == PanningDirectionUp : direction == PanningDirectionDown) :
        (interactor.isAppearing ? direction == PanningDirectionLeft : direction == PanningDirectionRight);
}

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    [super setAllowsInteraction:allowsInteraction];
    _appearenceInteractor.gestureRecognizer.enabled = allowsInteraction;
    _disappearenceInteractor.gestureRecognizer.enabled = allowsInteraction;
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController]) {
        return;
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_disappearenceInteractor attach:_viewController presentViewController:nil];
}

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _currentInteractor = _disappearenceInteractor;
    _transitioning = [self transitioningForDismissedController:dismissed];
    _transitioning.allowsDeactivating = self.allowsDeactivating;
    _transitioning.isAllowsAppearanceTransition = self.isAllowsAppearanceTransition;
    _transitioning.options = self.disappearenceOptions;
    return _transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _currentInteractor = _appearenceInteractor;
    _transitioning = [self transitioningForForPresentedController:presented presentingController:presenting sourceController:source];
    _transitioning.allowsDeactivating = self.allowsDeactivating;
    _transitioning.isAllowsAppearanceTransition = self.isAllowsAppearanceTransition;
    _transitioning.options = self.appearenceOptions;
    ((AnimatedTransitioning *) _transitioning).presenting = YES;
    return _transitioning;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.isInteracting) ? _disappearenceInteractor : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.isInteracting) ? _appearenceInteractor : nil;
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
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    transition.viewController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, &AssociatedKeyTransition);
}

@end
