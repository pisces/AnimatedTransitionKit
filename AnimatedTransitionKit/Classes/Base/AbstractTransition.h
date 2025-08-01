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
//  AbstractTransition.h
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 8/14/17.
//

#import "AbstractAnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"
#import "TransitioningAnimationOptions.h"

@protocol AbstractTransitionProtected <NSObject>
- (void)initProperties;
- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor
       transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion;
- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor
                   percent:(CGFloat)percent;
- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor
                  completion:(void (^_Nullable)(void))completion;
@end

@interface AbstractTransition: NSObject <AbstractTransitionProtected>
@property (nonatomic, getter=isAllowsDeactivating) BOOL allowsDeactivating;
@property (nonatomic, getter=isAllowsInteraction) BOOL allowsInteraction;
@property (nonatomic, readonly, getter=isInteracting) BOOL interacting;
@property (nonatomic, getter=isAllowsAppearanceTransition) BOOL allowsAppearanceTransition;
@property (nullable, nonatomic, readonly) AbstractInteractiveTransition *currentInteractor;
@property (nullable, nonatomic) AbstractAnimatedTransitioning *transitioning;
@property (nonnull, nonatomic, strong) TransitioningAnimationOptions *disappearenceOptions;
@property (nonnull, nonatomic, strong) TransitioningAnimationOptions *appearenceOptions;
- (void)beginInteration;
- (void)clear;
- (void)endInteration;
- (BOOL)isAppearing:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)isDisappearing:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)isValid:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)shouldCompleteInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)setViewControllerForAppearing:(UIViewController * _Nonnull)viewController;
@end
