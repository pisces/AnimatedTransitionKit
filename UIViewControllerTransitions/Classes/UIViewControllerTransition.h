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
//  UIViewControllerTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//

#import <UIKit/UIKit.h>
#import "AbstractTransition.h"
#import "AnimatedTransitioning.h"

@protocol UIViewControllerTransitionProtected <NSObject>
- (AnimatedTransitioning * _Nullable)transitioningForDismissedController:(UIViewController * _Nullable)dismissed;
- (AnimatedTransitioning * _Nullable)transitioningForForPresentedController:(UIViewController * _Nullable)presented presentingController:(UIViewController * _Nullable)presenting sourceController:(UIViewController * _Nullable)source;
@end

@interface UIViewControllerTransition : AbstractTransition <UIViewControllerTransitioningDelegate, UIViewControllerTransitionProtected>
@property (nonatomic) UIViewAnimationOptions animationOptionsForDismission;
@property (nonatomic) UIViewAnimationOptions animationOptionsForPresenting;
@property (nonatomic) NSTimeInterval durationForDismission;
@property (nonatomic) NSTimeInterval durationForPresenting;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *dismissionInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *presentingInteractor;
@property (nullable, nonatomic, weak) UIViewController *viewController;
@end

@interface UIViewController (UIViewControllerTransitions)
@property (nullable, nonatomic, weak) UIViewControllerTransition *transition;
@end
