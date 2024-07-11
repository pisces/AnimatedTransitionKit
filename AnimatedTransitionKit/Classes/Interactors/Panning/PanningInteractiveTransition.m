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
//  AnimatedTransitionKit
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
@property (nonatomic, readonly) BOOL shouldInteractiveTransition;
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation PanningInteractiveTransition
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize shouldComplete = _shouldComplete;

#pragma mark - Public Properties

- (PanningDirection)panningDirection {
    return _selectedPanGestureRecognizer.panningDirection;
}

#pragma mark - Private Properties

- (BOOL)shouldBeginInteraction {
    if (![self.transition isValid:self]) {
        return NO;
    }
    if ([self.transition isAppearing:self]) {
        return self.presentViewController != nil;
    }
    return self.viewController != nil;
}

- (BOOL)shouldInteractiveTransition {
    BOOL shouldTransitionOfTransitioning = _selectedPanGestureRecognizer == self.drivingScrollView.panGestureRecognizer && self.transition.transitioning ?
        [self.transition.transitioning shouldTransition:self] :
        YES;
    BOOL shouldTransitionOfDelegate = ![self.delegate respondsToSelector:@selector(shouldTransition:)] || [self.delegate shouldTransition:self];
    return shouldTransitionOfTransitioning && shouldTransitionOfDelegate;
}

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return (UIPanGestureRecognizer *) _gestureRecognizer;
}

#pragma mark - Con(De)structors

- (void)dealloc {
    [self detach];
}

- (id)init {
    self = [super init];
    if (self) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        _gestureRecognizer.delegate = self;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return self;
}

#pragma mark - Overridden: AbstractInteractiveTransition

- (void)detach {
    [super detach];
    
    if (self.drivingScrollView) {
        [self.drivingScrollView.panGestureRecognizer removeTarget:self action:@selector(panned:)];
    }
}

- (CGFloat)translationOffset {
    return _selectedPanGestureRecognizer == self.drivingScrollView.panGestureRecognizer ?
        [super translationOffset] :
        0;
}

- (CGPoint)translation {
    return [_selectedPanGestureRecognizer translationInView:self.currentViewController.view.superview];
}

- (CGPoint)velocity {
    return [_selectedPanGestureRecognizer velocityInView:self.currentViewController.view];
}

- (void)setDrivingScrollView:(UIScrollView *)drivingScrollView {
    [super setDrivingScrollView:drivingScrollView];
    [drivingScrollView.panGestureRecognizer addTarget:self action:@selector(panned:)];
}

#pragma mark - Protected Methods

- (BOOL)beginInteractiveTransition {
    if ([self.transition isAppearing:self]) {
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

- (void)beginInterationIfAvailable {
    if (!self.shouldBeginInteraction ||
        self.transition.transitioning.isAnimating ||
        self.transition.isInteracting ||
        !self.shouldInteractiveTransition ||
        ([self.delegate respondsToSelector:@selector(interactor:shouldInteract:)] &&
        ![self.delegate interactor:self shouldInteract:_selectedPanGestureRecognizer])) {
        return;
    }
    
    [self.transition beginInteration];
    
    if (![self beginInteractiveTransition]) {
        [self.transition endInteration];
    }
}

- (void)panningBegan {
    _shouldComplete = NO;
    _startPanningDirection = self.selectedPanGestureRecognizer.panningDirection;
    [self.transition.transitioning updateTranslationOffset:self];
}

#pragma mark - Private Selectors

- (void)panned:(UIPanGestureRecognizer *)panGestureRecognizer {
    _selectedPanGestureRecognizer = panGestureRecognizer;
    
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            [self panningBegan];
            [self beginInterationIfAvailable];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.shouldBeginWhenGestureChanged) {
                [self beginInterationIfAvailable];
            }
            
            if (!self.transition.isInteracting ||
                ![self.transition.currentInteractor isEqual:self] ||
                !self.shouldInteractiveTransition) {
                return;
            }

            const CGSize screenSize = UIScreen.mainScreen.bounds.size;
            CGFloat translationValue;
            CGFloat targetSize;
            switch (self.direction) {
                case InteractiveTransitionDirectionVertical:
                    translationValue = self.translation.y;
                    targetSize = screenSize.height;
                    break;
                case InteractiveTransitionDirectionHorizontal:
                    translationValue = self.translation.x;
                    targetSize = screenSize.width;
                    break;
                case InteractiveTransitionDirectionAll:
                    translationValue = self.translation.x + self.translation.y;
                    targetSize = screenSize.width + screenSize.height;
                    break;
            }

            const BOOL isAppearing = [self.transition isAppearing:self];
            const CGFloat fixedTranslationValue = translationValue - self.translationOffset;
            const CGFloat velocityValue = self.isVertical ? self.velocity.y : self.velocity.x;
            const CGFloat interactionDistance = targetSize * (isAppearing ? -1 : 1);
            const CGFloat percent = fmin(fmax(-1, fixedTranslationValue / interactionDistance), 1);
            const CGFloat multiply = MAX(1, ABS(velocityValue / 300));
            const CGFloat percentForComparison = ABS(percent * multiply);

            _shouldComplete = percentForComparison > self.percentForCompletion && [self.transition shouldCompleteInteractor:self];
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.isInteracting || ![self.transition.currentInteractor isEqual:self]) {
                [self.transition endInteration];
                return;
            }
            
            if (panGestureRecognizer.state == UIGestureRecognizerStateEnded && _shouldComplete) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            
            [self.transition endInteration];
            break;
        }
        default:
            break;
    }
}

@end
