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
//  AbstractInteractiveTransition.h
//  AnimatedTransitionKit
//
//  Created by pisces on 13/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InteractiveTransitionDirection) {
    InteractiveTransitionDirectionVertical,
    InteractiveTransitionDirectionHorizontal,
    InteractiveTransitionDirectionAll,
};

@class AbstractTransition;

@protocol InteractiveTransitionDataSource;
@protocol InteractiveTransitionDelegate;

@interface AbstractInteractiveTransition : UIPercentDrivenInteractiveTransition <UIGestureRecognizerDelegate>
@property (nonatomic, readonly, getter=isAppearing) BOOL appearing;
@property (nonatomic, readonly, getter=isInteractionEnabled) BOOL interactionEnabled;
@property (nonatomic, readonly, getter=isVertical) BOOL vertical;
@property (nonatomic, readonly) BOOL shouldComplete;
@property (nonatomic) BOOL shouldBeginWhenGestureChanged;
@property (nonatomic, readonly) CGFloat percentForCompletion;
@property (nonatomic) CGFloat translationOffset;
@property (nonatomic) InteractiveTransitionDirection direction;
@property (nonatomic, readonly) CGPoint translation;
@property (nonatomic, readonly) CGPoint velocity;
@property (nonnull, nonatomic, readonly) UIGestureRecognizer *gestureRecognizer;
@property (nullable, nonatomic, weak) id<InteractiveTransitionDelegate> delegate;
@property (nullable, nonatomic, weak) id<InteractiveTransitionDataSource> dataSource;
@property (nullable, nonatomic, weak) UIScrollView *drivingScrollView;
@property (nullable) UIViewController *viewControllerForAppearing;
@property (nullable, weak, readonly) UIViewController *viewController;
@property (nonnull, readonly) UIViewController *currentViewController;
@property (nullable, weak) AbstractTransition *transition;
- (void)attach:(__weak UIViewController * _Nonnull)viewController;
- (void)detach;
- (void)clear;
@end

@protocol InteractiveTransitionDelegate <NSObject>
@optional
- (void)didBeginWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didChangeWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)didCancelWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didCompleteWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)shouldTransition:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)willCancelWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)willCompleteWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizerShouldBegin:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldReceiveTouch:(UITouch * _Nullable)touch;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor shouldInteract:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
@end

@protocol InteractiveTransitionDataSource <NSObject>
- (nullable UIViewController *)viewControllerForAppearing:(AbstractInteractiveTransition * _Nonnull)interactor;
@end
