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
//  UINavigationControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//

#import "UINavigationControllerTransition.h"
#import "NavigationPanningInteractiveTransition.h"
#import "UIViewControllerTransitionOptions.h"
#import <objc/runtime.h>

@interface UINavigationControllerTransition ()
@property (nonatomic, readonly) BOOL isPush;
@property (nullable, nonatomic, readonly) AnimatedNavigationTransitioning *navigationTransitioning;
@end

@implementation UINavigationControllerTransition
@synthesize transitioning = _transitioning;

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
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).startPanningDirection;
    return direction == PanningDirectionLeft;
}

- (BOOL)isValid:(AbstractInteractiveTransition *)interactor {
    return self.isPush ? [self isAppearing:interactor] : YES;
}

- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    return self.isPush ? direction == PanningDirectionLeft : direction == PanningDirectionRight;
}

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    [super setAllowsInteraction:allowsInteraction];
    
    _interactor.gestureRecognizer.enabled = allowsInteraction;
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    if ([navigationController isEqual:_navigationController]) {
        return;
    }
    
    _navigationController = navigationController;
    _navigationController.delegate = self;
    
    [_interactor attach:_navigationController presentViewController:nil];
}

- (void)initProperties {
    [super initProperties];
    
    _interactor = [NavigationPanningInteractiveTransition new];
    _interactor.direction = InteractiveTransitionDirectionHorizontal;
    
    self.allowsInteraction = YES;
    self.appearenceOptions.duration = self.disappearenceOptions.duration = UINavigationControllerHideShowBarDuration;
}

#pragma mark - UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    BOOL isPush = operation == UINavigationControllerOperationPush;
    if (!_transitioning) {
        AnimatedNavigationTransitioning *transitioning = [self newTransitioning];
        transitioning.appearenceOptions = self.appearenceOptions;
        transitioning.disappearenceOptions = self.disappearenceOptions;
        _transitioning = transitioning;
    }
    self.navigationTransitioning.push = isPush;
    return _transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                      interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.currentInteractor ? (id<UIViewControllerAnimatedTransitioning>) self.currentInteractor : nil;
}

#pragma mark - Protected methods

- (AnimatedNavigationTransitioning *)newTransitioning {
    return nil;
}

#pragma mark - Private methods

- (BOOL)isPush {
    return self.navigationTransitioning == nil || self.navigationTransitioning.isPush;
}

- (AnimatedNavigationTransitioning *)navigationTransitioning {
    return (AnimatedNavigationTransitioning *) _transitioning;
}

@end

static void *AssociatedKeyNavigationTransition = @"navigationTransition";

@implementation UINavigationController (UIViewControllerTransitions)

- (void)setNavigationTransition:(UINavigationControllerTransition *)navigationTransition {
    if ([navigationTransition isEqual:[self navigationTransition]])
        return;
    
    navigationTransition.navigationController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyNavigationTransition, navigationTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationControllerTransition *)navigationTransition {
    return objc_getAssociatedObject(self, &AssociatedKeyNavigationTransition);
}

@end
