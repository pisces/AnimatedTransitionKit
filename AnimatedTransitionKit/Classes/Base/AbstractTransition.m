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
//  AbstractTransition.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 8/14/17.
//

#import "AbstractTransition.h"

@implementation AbstractTransition

#pragma mark - Con(De)structor

- (void)dealloc {
    [self clear];
}

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

#pragma mark - Public Methods

- (void)beginInteration {
    _interacting = YES;
}

- (void)clear {
    [self.transitioning clear];
}

- (void)endInteration {
    _interacting = NO;
}

- (BOOL)isValid:(AbstractInteractiveTransition * _Nonnull)interactor {
    return NO;
}

- (BOOL)isAppearing:(AbstractInteractiveTransition *)interactor {
    return NO;
}

- (BOOL)isDisappearing:(AbstractInteractiveTransition *)interactor {
    return NO;
}

- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition *)interactor {
    return YES;
}

#pragma mark - Protected Methods

- (void)initProperties {
    _allowsDeactivating = NO;
    _allowsInteraction = YES;
    _allowsAppearanceTransition = YES;
    _appearenceOptions = [[TransitioningAnimationOptions new] initWithDuration:UINavigationControllerHideShowBarDuration
                                                                         delay:0
                                                              animationOptions:7 << 16
                                                                 isUsingSpring:NO
                                                        usingSpringWithDamping:0.6
                                                         initialSpringVelocity:1.0];
    _disappearenceOptions = [[TransitioningAnimationOptions new] initWithDuration:UINavigationControllerHideShowBarDuration
                                                                            delay:0
                                                                 animationOptions:7 << 16
                                                                    isUsingSpring:NO
                                                           usingSpringWithDamping:0.6
                                                            initialSpringVelocity:1.0];
}

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor
       transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [_transitioning startAnimating];
    [_transitioning interactionBegan:interactor transitionContext:transitionContext];
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion {
    [_transitioning interactionCancelled:interactor completion:completion];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor
                   percent:(CGFloat)percent {
    [_transitioning interactionChanged:interactor percent:percent];
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion {
    [_transitioning interactionCompleted:interactor completion:completion];
}

@end
