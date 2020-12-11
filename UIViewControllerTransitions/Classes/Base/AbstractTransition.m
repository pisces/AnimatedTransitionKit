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
//  AbstractTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//

#import "AbstractTransition.h"
#import "PanningInteractiveTransition.h"

@implementation AbstractTransition

#pragma mark - Con(De)structor

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

- (BOOL)isAppearingWithInteractor:(AbstractInteractiveTransition *)interactor {
    return NO;
}

- (BOOL)isValidWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor {
    return NO;
}

#pragma mark - Protected Methods

- (void)initProperties {
    _appearenceOptions = [[UIViewControllerTransitionOptions new] initWithDuration:0.35
                                                           animationOptions:7 << 16
                                                              isUsingSpring:NO
                                                     usingSpringWithDamping:0.6
                                                      initialSpringVelocity:1.0];
    _disappearenceOptions = [[UIViewControllerTransitionOptions new] initWithDuration:0.35
                                                           animationOptions:7 << 16
                                                              isUsingSpring:NO
                                                     usingSpringWithDamping:0.6
                                                      initialSpringVelocity:1.0];
}

@end
