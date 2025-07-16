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

struct Percent {
    CGFloat rawValue;
    CGFloat processedValue;
};
typedef struct Percent Percent;

Percent PercentMake(CGFloat rawValue, CGFloat processedValue) {
    Percent percent;
    percent.rawValue = rawValue;
    percent.processedValue = processedValue;
    return percent;
}

const Percent PercentZero;

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
        if (!self.viewControllerForAppearing) {
            self.viewControllerForAppearing = [self.dataSource viewControllerForAppearing:self];
        }
        return self.viewControllerForAppearing != nil;
    }
    return YES;
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

- (CGFloat)percentForCompletion {
    switch (self.direction) {
        case InteractiveTransitionDirectionVertical:
            return 0.15;
        case InteractiveTransitionDirectionHorizontal:
            return 0.5;
        case InteractiveTransitionDirectionAll:
            const BOOL isVertical = PanningDirectionIsVertical(self.startPanningDirection);
            return isVertical ? 0.15 : 0.5;
        default:
            return 0.5;
    }
}

- (void)detach {
    [super detach];
    
    if (self.drivingScrollView) {
        [self.drivingScrollView.panGestureRecognizer removeTarget:self action:@selector(panned:)];
    }
}

- (void)clear {
    [super clear];
    _startPanningDirection = PanningDirectionNone;
}

- (CGFloat)translationOffset {
    return _selectedPanGestureRecognizer == self.drivingScrollView.panGestureRecognizer ?
        [super translationOffset] :
        0;
}

- (CGPoint)translation {
    const CGPoint point = [_selectedPanGestureRecognizer translationInView:self.currentViewController.view.superview];
    return CGPointMake(point.x * 1.2, point.y * 1.2);
}

- (CGPoint)velocity {
    return [_selectedPanGestureRecognizer velocityInView:self.currentViewController.view];
}

- (void)setDrivingScrollView:(UIScrollView *)drivingScrollView {
    [super setDrivingScrollView:drivingScrollView];
    [drivingScrollView.panGestureRecognizer addTarget:self action:@selector(panned:)];
}

#pragma mark - Protected

- (BOOL)beginInteractiveTransition {
    if ([self.transition isAppearing:self]) {
        if (!self.viewControllerForAppearing) {
            return NO;
        }
        [self.viewController presentViewController:self.viewControllerForAppearing animated:YES completion:nil];
    } else {
        if (!self.viewController) {
            return NO;
        }
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

#pragma mark - Private

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

            Percent percent = [self percentWhenPanningChanged];
            _shouldComplete = percent.processedValue > self.percentForCompletion && [self.transition shouldCompleteInteractor:self];
            [self updateInteractiveTransition:percent.rawValue];
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

- (Percent)percentWhenPanningChanged {
    const CGSize screenSize = UIScreen.mainScreen.bounds.size;
    switch (self.direction) {
        case InteractiveTransitionDirectionVertical:
            return [self percentWithTranslation:self.translation.y
                                           size:screenSize.height
                                       velocity:self.velocity.y];
        case InteractiveTransitionDirectionHorizontal:
            return [self percentWithTranslation:self.translation.x
                                           size:screenSize.width
                                       velocity:self.velocity.x];
        case InteractiveTransitionDirectionAll:
            return [self percentForDirectionAllWithScreenSize:screenSize];
    }
}

- (Percent)percentForDirectionAllWithScreenSize:(CGSize)screenSize {
    Percent verticalPercent = [self percentWithTranslation:self.translation.y
                                                      size:screenSize.height
                                                  velocity:self.velocity.y];
    Percent horizontalPercent = [self percentWithTranslation:self.translation.x
                                                        size:screenSize.width
                                                    velocity:self.velocity.x];
    const BOOL isStartPanningDirectionVertical = PanningDirectionIsVertical(self.startPanningDirection);

    if (isStartPanningDirectionVertical) {
        return verticalPercent.processedValue > horizontalPercent.processedValue ? verticalPercent : PercentZero;
    }
    return horizontalPercent.processedValue > verticalPercent.processedValue ? horizontalPercent : PercentZero;
}

- (Percent)percentWithTranslation:(CGFloat)translation
                             size:(CGFloat)size
                         velocity:(CGFloat)velocity {
    const BOOL isAppearing = [self.transition isAppearing:self];
    const CGFloat bounds = translation - self.translationOffset;
    const CGFloat interactionDistance = size * (isAppearing ? -1 : 1);
    const CGFloat rawValue = fmin(fmax(-1, bounds / interactionDistance), 1);
    const CGFloat multiply = MAX(1, ABS(velocity / 300));
    const CGFloat processedValue = ABS(rawValue * multiply);
    return PercentMake(rawValue, processedValue);
}

@end
