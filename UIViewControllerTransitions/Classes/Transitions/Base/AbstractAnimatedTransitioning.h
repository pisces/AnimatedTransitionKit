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
//  AbstractAnimatedTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//

#import <UIKit/UIKit.h>

@class AbstractInteractiveTransition;

@interface AbstractAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, getter=isAnimating, readonly) BOOL animating;
@property (nonatomic, getter=isUsingSpring) BOOL usingSpring;
@property (nonatomic) CGFloat completionBounds;
@property (nonatomic) CGFloat initialSpringVelocity;
@property (nonatomic) CGFloat usingSpringWithDamping;
@property (nonatomic, readonly) CGFloat percentOfBounds;
@property (nonatomic, readonly) CGFloat percentOfInteraction;
@property (nonatomic, readonly) CGFloat heightRatio;
@property (nonatomic, readonly) CGFloat widthRatio;
@property (nonatomic) UIViewAnimationOptions animationOptions;
@property (nonatomic) NSTimeInterval duration;
@property (nullable, nonatomic, weak) id <UIViewControllerContextTransitioning> context;
@property (nullable, nonatomic, weak) UIViewController *fromViewController;
@property (nullable, nonatomic, weak) UIViewController *toViewController;
@property (nullable, nonatomic, readonly) UIViewController *belowViewController;
@property (nullable, nonatomic, readonly) UIViewController *aboveViewController;

- (void)animate:(void (^ _Nullable)(void))animations
     completion:(void (^ _Nullable)(void))completion;

- (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^ _Nullable)(void))animations
                 completion:(void (^ _Nullable)(void))completion;

- (void)clear;
- (void)endAnimating;

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor
       transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion;

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor
                   percent:(CGFloat)percent;

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion;

- (void)startAnimating;
- (void)updatePercentOfBounds;
@end
