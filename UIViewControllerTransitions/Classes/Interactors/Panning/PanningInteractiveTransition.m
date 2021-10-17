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
//  PanningInteractiveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 11/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import <UIKit/UIKit.h>
#import "PanningInteractiveTransition.h"
#import "AbstractTransition.h"
#import "UIScrollView+Utils.h"

@interface PanningInteractiveTransition ()
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation PanningInteractiveTransition
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize shouldComplete = _shouldComplete;

#pragma mark - Public Properties

- (PanningDirection)panningDirection {
    return self.panGestureRecognizer.panningDirection;
}

#pragma mark - Private Properties

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return (UIPanGestureRecognizer *) _gestureRecognizer;
}

- (BOOL)shouldBeginInteraction {
    if (![self.transition isValidWithInteractor:self]) {
        return NO;
    }
    if ([self.transition isAppearingWithInteractor:self]) {
        return self.presentViewController != nil;
    }
    return self.viewController != nil;
}

#pragma mark - Con(De)structors

- (void)dealloc {
    [self detach];
    [_gestureRecognizer removeTarget:self action:@selector(panned)];
}

- (id)init {
    self = [super init];
    if (self) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned)];
        _gestureRecognizer.delegate = self;
        _gestureRecognizer.enabled = NO;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return self;
}

#pragma mark - Overridden: AbstractInteractiveTransition

- (CGPoint)translation {
    return [self.panGestureRecognizer translationInView:self.currentViewController.view.superview];
}

#pragma mark - Protected Methods

- (BOOL)beginInteractiveTransition {
    if ([self.transition isAppearingWithInteractor:self]) {
        if (!self.presentViewController) {
            return NO;
        }
        [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
    } else {
        if (!self.viewController) {
            return NO;
        }
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

#pragma mark - Private Methods

- (void)panningBegan {
    _startPanningDirection = self.panGestureRecognizer.panningDirection;
    
    if (!self.shouldBeginInteraction ||
        self.transition.transitioning.isAnimating ||
        self.transition.isInteracting ||
        ([self.delegate respondsToSelector:@selector(interactor:shouldInteract:)] &&
        ![self.delegate interactor:self shouldInteract:_gestureRecognizer])) {
        return;
    }
    
    [self.transition beginInteration];
    
    if (![self beginInteractiveTransition]) {
        [self.transition endInteration];
    }
}

#pragma mark - Private Selectors

- (void)panned {
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self panningBegan];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transition.isInteracting ||
                ![self.transition.currentInteractor isEqual:self] ||
                ![self.transition.transitioning shouldTransition:self] ||
                ([self.delegate respondsToSelector:@selector(shouldTransition:)] &&
                 ![self.delegate shouldTransition:self])) {
                return;
            }
            
            const BOOL isAppearing = [self.transition isAppearingWithInteractor:self];
            const CGFloat translationOffset = self.transition.transitioning.translationOffset;
            const CGPoint translation = self.translation;
            const CGFloat translationValue = (self.isVertical ? translation.y : translation.x) - translationOffset;
            const CGFloat targetSize = self.isVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat dragAmount = targetSize * (isAppearing ? -1 : 1);
            const CGFloat percent = fmin(fmax(-1, translationValue / dragAmount), 1);
            
            _shouldComplete = ABS(percent) > 0.3;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.isInteracting || ![self.transition.currentInteractor isEqual:self]) {
                [self.transition endInteration];
                return;
            }
            
            if (_gestureRecognizer.state == UIGestureRecognizerStateEnded && _shouldComplete) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            
            [self.transition endInteration];
            _shouldComplete = NO;
            break;
        }
        default:
            break;
    }
}

@end
