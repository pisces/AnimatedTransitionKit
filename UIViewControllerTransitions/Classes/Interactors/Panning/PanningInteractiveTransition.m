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
//  PanningInteractiveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 11/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "PanningInteractiveTransition.h"
#import "AbstractTransition.h"

BOOL PanningDirectionIsVertical(PanningDirection direction) {
    return direction == PanningDirectionUp || direction == PanningDirectionDown;
}

@interface PanningInteractiveTransition ()
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation PanningInteractiveTransition
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize shouldComplete = _shouldComplete;
@synthesize beginPoint = _beginPoint;
@synthesize beginViewPoint = _beginViewPoint;
@synthesize point = _point;

#pragma mark - Public Properties

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return (UIPanGestureRecognizer *) _gestureRecognizer;
}

#pragma mark - Private Properties

- (BOOL)shouldBeginInteraction {
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
    _panningDirection = self.panGestureRecognizer.panningDirection;
    
    if (!self.shouldBeginInteraction ||
        self.transition.transitioning.isAnimating ||
        self.transition.isInteracting ||
        ![self.transition isValidWithInteractor:self] ||
        ([self.delegate respondsToSelector:@selector(interactor:shouldInteractionWithGestureRecognizer:)] &&
        ![self.delegate interactor:self shouldInteractionWithGestureRecognizer:_gestureRecognizer])) {
        return;
    }
    
    [self.transition beginInteration];
    
    _beginPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    _beginViewPoint = self.currentViewController.view.frame.origin;
    
    if (![self beginInteractiveTransition]) {
        [self.transition endInteration];
    }
}

#pragma mark - Private Selectors

- (void)panned {
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self panningBegan];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transition.isInteracting ||
                ![self.transition.currentInteractor isEqual:self] ||
                ([self.delegate respondsToSelector:@selector(shouldChangeWithInteractor:)] &&
                 ![self.delegate shouldChangeWithInteractor:self])) {
                [self panningBegan];
                _beginPoint = newPoint;
                _beginViewPoint = self.currentViewController.view.frame.origin;
                return;
            }
            
            const BOOL isAppearing = [self.transition isAppearingWithInteractor:self];
            const CGPoint translation = [self.panGestureRecognizer translationInView:self.currentViewController.view.superview];
            const CGPoint velocity = [self.panGestureRecognizer velocityInView:self.currentViewController.view.superview];
            const CGFloat translationValue = self.isVertical ? translation.y : translation.x;
            const CGFloat velocityValue = self.isVertical ? velocity.y : velocity.x;
            const CGFloat targetSize = self.isVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat dragAmount = targetSize * (isAppearing ? -1 : 1);
            const CGFloat threshold = self.transition.transitioning.completionBounds / targetSize;
            const CGFloat percent = fmin(fmax(-1, translationValue / dragAmount), 1);
            const CGFloat addendValue = isAppearing ? (velocityValue < 0 ? velocityValue : 0) : (velocityValue > 0 ? velocityValue : 0);
            const CGFloat completionFactor = ABS(((newPoint.y - _beginPoint.y) + addendValue) / dragAmount);
            
            _point = newPoint;
            _shouldComplete = completionFactor > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.isInteracting || ![self.transition.currentInteractor isEqual:self]) {
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

@implementation UIPanGestureRecognizer (UIViewControllerTransitions)
- (PanningDirection)panningDirection {
    CGPoint velocity = [self velocityInView:self.view];
    CGFloat ratio = UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width;
    BOOL vertical = fabs(velocity.y) > fabs(velocity.x * ratio);
    
    if (vertical) {
        if (velocity.y < 0) return PanningDirectionUp;
        if (velocity.y > 0) return PanningDirectionDown;
    }
    
    if (velocity.x > 0) return PanningDirectionRight;
    if (velocity.x < 0) return PanningDirectionLeft;
    
    return PanningDirectionNone;
}

@end
