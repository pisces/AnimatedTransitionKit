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
//  MoveTransition.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 5/13/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename UIViewControllerMoveTransition to MoveTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//

#import "MoveTransition.h"
#import "MoveTransitioning.h"
#import "AnimatedTransitionKitMacro.h"
#import "PanningInteractiveTransition.h"
#import "UIScrollView+Utils.h"

@interface MoveTransition () <InteractiveTransitionDelegate>
@end

@implementation MoveTransition

#pragma mark - Properties

- (BOOL)interactiveTransitionDirection {
    return (_direction == MoveTransitioningDirectionLeft || _direction == MoveTransitioningDirectionRight) ? InteractiveTransitionDirectionHorizontal : InteractiveTransitionDirectionVertical;
}

- (void)setDirection:(MoveTransitioningDirection)direction {
    if (direction == _direction) {
        return;
    }
    _direction = direction;
    self.appearenceInteractor.direction = self.disappearenceInteractor.direction = self.interactiveTransitionDirection;
}

#pragma mark - Overridden: AnimatedTransition

- (BOOL)isAppearing:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).startPanningDirection;
    if (_direction == MoveTransitioningDirectionUp) {
        return direction == PanningDirectionUp;
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return direction == PanningDirectionDown;
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return direction == PanningDirectionLeft;
    }
    return direction == PanningDirectionRight;
}

- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    if (_direction == MoveTransitioningDirectionUp) {
        return interactor.isAppearing ? direction == PanningDirectionUp : direction == PanningDirectionDown;
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return interactor.isAppearing ? direction == PanningDirectionDown : direction == PanningDirectionUp;
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return interactor.isAppearing ? direction == PanningDirectionLeft : direction == PanningDirectionRight;
    }
    return interactor.isAppearing ? direction == PanningDirectionRight : direction == PanningDirectionLeft;
}

- (id)init {
    self = [super init];
    if (self) {
        _direction = MoveTransitioningDirectionUp;
    }
    return self;
}

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    MoveTransitioning *transitioning = [MoveTransitioning new];
    transitioning.direction = _direction;
    return transitioning;
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MoveTransitioning *transitioning = [MoveTransitioning new];
    transitioning.direction = _direction;
    return transitioning;
}

@end
