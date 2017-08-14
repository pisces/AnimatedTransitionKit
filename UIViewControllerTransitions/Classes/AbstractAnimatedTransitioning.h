//
//  AbstractAnimatedTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import <UIKit/UIKit.h>

@class AbstractInteractiveTransition;

@interface AbstractAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, getter=isAnimating, readonly) BOOL animating;
@property (nonatomic) CGFloat completionBounds;
@property (nonatomic, readonly) CGFloat percentOfBounds;
@property (nonatomic, readonly) CGFloat heightRatio;
@property (nonatomic, readonly) CGFloat widthRatio;
@property (nonatomic) UIViewAnimationOptions animationOptions;
@property (nonatomic) NSTimeInterval duration;
@property (nullable, nonatomic, weak) id <UIViewControllerContextTransitioning> context;
@property (nullable, nonatomic, weak) UIViewController *fromViewController;
@property (nullable, nonatomic, weak) UIViewController *toViewController;
@property (nullable, nonatomic, readonly) UIViewController *belowViewController;
@property (nullable, nonatomic, readonly) UIViewController *aboveViewController;
- (void)clear;
- (void)endAnimating;
- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
- (BOOL)shouldComplete:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)startAnimating;
@end
