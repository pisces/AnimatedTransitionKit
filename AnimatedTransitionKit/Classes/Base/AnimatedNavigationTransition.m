//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~, Steve Kim
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
//  AnimatedNavigationTransition.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 8/13/17.
//

#import "AnimatedNavigationTransition.h"
#import "NavigationPanningInteractiveTransition.h"
#import "TransitioningAnimationOptions.h"
#import <objc/runtime.h>

@interface AnimatedNavigationTransition ()
@property (nullable, nonatomic, weak) id<UINavigationControllerDelegate> originNavigationDelegate;
@property (nullable, nonatomic, readonly) AnimatedNavigationTransitioning *navigationTransitioning;
@end

@implementation AnimatedNavigationTransition
@synthesize isEnabled = _isEnabled;
@synthesize transitioning = _transitioning;

- (void)dealloc {
    self.isEnabled = NO;
}

#pragma mark - Overridden: AbstractTransition

- (AbstractInteractiveTransition *)currentInteractor {
    if (self.isAllowsInteraction && self.isInteracting) {
        return _interactor;
    }
    return nil;
}

- (BOOL)isAppearing:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]] ||
        !self.isPush) {
        return NO;
    }
    
    PanningDirection panningDirection = ((PanningInteractiveTransition *) interactor).startPanningDirection;

    switch (interactor.direction) {
        case InteractiveTransitionDirectionHorizontal:
            return panningDirection == PanningDirectionLeft;
        case InteractiveTransitionDirectionVertical:
            return panningDirection == PanningDirectionUp;
        case InteractiveTransitionDirectionAll:
            return panningDirection == PanningDirectionLeft || panningDirection == PanningDirectionUp;
    }
}

- (BOOL)isValid:(AbstractInteractiveTransition *)interactor {
    return self.isPush ? [self isAppearing:interactor] : YES;
}

- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }

    PanningDirection panningDirection = ((PanningInteractiveTransition *) interactor).panningDirection;

    switch (interactor.direction) {
        case InteractiveTransitionDirectionHorizontal:
            return self.isPush 
                ? panningDirection == PanningDirectionLeft
                : panningDirection == PanningDirectionRight;
        case InteractiveTransitionDirectionVertical:
            return self.isPush 
                ? panningDirection == PanningDirectionUp
                : panningDirection == PanningDirectionDown;
        case InteractiveTransitionDirectionAll:
            return self.isPush
                ? (panningDirection == PanningDirectionLeft || panningDirection == PanningDirectionUp)
                : (panningDirection == PanningDirectionRight || panningDirection == PanningDirectionDown);
    }
}

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    [super setAllowsInteraction:allowsInteraction];
    
    _interactor.gestureRecognizer.enabled = allowsInteraction;
}

- (void)setIsEnabled:(BOOL)isEnabled {
    if (isEnabled == _isEnabled) {
        return;
    }

    _isEnabled = isEnabled;

    [self activateOrDeactivate];
}

- (BOOL)isPush {
    return self.navigationTransitioning == nil || self.navigationTransitioning.isPush;
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    if ([navigationController isEqual:_navigationController]) {
        return;
    }

    if (!_navigationController) {
        BOOL isNavigationTransition = [navigationController.delegate isKindOfClass:[AnimatedNavigationTransition class]];
        if (isNavigationTransition) {
            AnimatedNavigationTransition *navigationTransition = (AnimatedNavigationTransition *) navigationController.delegate;
            _originNavigationDelegate = navigationTransition.originNavigationDelegate;
        } else {
            _originNavigationDelegate = navigationController.delegate;
        }
    }
    _navigationController = navigationController;
}

- (void)initProperties {
    [super initProperties];

    _isEnabled = NO;
    _interactor = [NavigationPanningInteractiveTransition new];
    _interactor.direction = InteractiveTransitionDirectionHorizontal;
    
    self.allowsInteraction = YES;
    self.appearenceOptions.duration = self.disappearenceOptions.duration = UINavigationControllerHideShowBarDuration;
}

#pragma mark - UINavigationController delegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    SEL selector = @selector(navigationController:willShowViewController:animated:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        [_originNavigationDelegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    SEL selector = @selector(navigationController:didShowViewController:animated:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        [_originNavigationDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    SEL selector = @selector(navigationControllerSupportedInterfaceOrientations:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        return [_originNavigationDelegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return navigationController.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController {
    SEL selector = @selector(navigationControllerPreferredInterfaceOrientationForPresentation:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        return [_originNavigationDelegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return navigationController.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                           animationControllerForOperation:(UINavigationControllerOperation)operation
                                                        fromViewController:(UIViewController *)fromVC
                                                          toViewController:(UIViewController *)toVC {
    BOOL shouldUseTransitioning = [self shouldUseTransitioningForOperation:operation fromVC:fromVC toVC:toVC];
    if (shouldUseTransitioning) {
        if (!_transitioning) {
            AnimatedNavigationTransitioning *transitioning = [self newTransitioning];
            transitioning.appearenceOptions = self.appearenceOptions;
            transitioning.disappearenceOptions = self.disappearenceOptions;
            _transitioning = transitioning;
        }
        self.navigationTransitioning.push = operation == UINavigationControllerOperationPush;
        return _transitioning;
    }

    SEL selector = @selector(navigationController:animationControllerForOperation:fromViewController:toViewController:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        self.isEnabled = NO;
        return [_originNavigationDelegate navigationController:navigationController
                               animationControllerForOperation:operation
                                            fromViewController:fromVC
                                              toViewController:toVC];
    }
    return nil;
}

- (nullable id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                  interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isEqual:_transitioning]) {
        return self.currentInteractor;
    }
    SEL selector = @selector(navigationController:interactionControllerForAnimationController:);
    if ([self shouldSendToOriginNavigationDelegate:selector]) {
        return [_originNavigationDelegate navigationController:navigationController
                   interactionControllerForAnimationController:animationController];
    }
    return nil;
}

#pragma mark - Protected methods

- (AnimatedNavigationTransitioning * _Nullable)newTransitioning {
    return nil;
}

- (BOOL)shouldUseTransitioningForOperation:(UINavigationControllerOperation)operation
                                       fromVC:(UIViewController * _Nullable)fromVC
                                         toVC:(UIViewController * _Nullable)toVC {
    return YES;
}

#pragma mark - Private methods

- (AnimatedNavigationTransitioning *)navigationTransitioning {
    return (AnimatedNavigationTransitioning *) _transitioning;
}

- (BOOL)shouldSendToOriginNavigationDelegate:(SEL)aSelector {
    return _originNavigationDelegate &&
        ![_originNavigationDelegate isKindOfClass:[AnimatedNavigationTransition self]] &&
        [_originNavigationDelegate respondsToSelector:aSelector];
}

- (void)activateOrDeactivate {
    if (!_navigationController) {
        return;
    }

    if (_isEnabled) {
        _navigationController.delegate = self;
        [_interactor attach:_navigationController presentViewController:nil];
    } else {
        [_interactor detach];
        _navigationController.delegate = _originNavigationDelegate;
    }
}

@end

static void *AssociatedKeyNavigationTransition = @"navigationTransition";

@implementation UINavigationController (AnimatedTransitionKit)

- (void)setNavigationTransition:(AnimatedNavigationTransition *)navigationTransition {
    if (![navigationTransition isEqual:self.navigationTransition]) {
        self.navigationTransition.isEnabled = NO;
        navigationTransition.navigationController = self;
        objc_setAssociatedObject(self, &AssociatedKeyNavigationTransition, navigationTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    navigationTransition.isEnabled = YES;
}

- (AnimatedNavigationTransition *)navigationTransition {
    return objc_getAssociatedObject(self, &AssociatedKeyNavigationTransition);
}

@end
