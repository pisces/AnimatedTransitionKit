//
//  AnimatedTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import <UIKit/UIKit.h>
#import "AbstractInteractiveTransition.h"

@protocol AnimatedTransitioningProtected <NSObject>
- (void)animateTransitionForDismission:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)animateTransitionForPresenting:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
@end

@interface AnimatedTransitioning : NSObject <AnimatedTransitioningProtected, UIViewControllerAnimatedTransitioning>
{
@protected
    CGFloat bouncePercent;
    id <UIViewControllerContextTransitioning> context;
    UIViewController *fromViewController;
    UIViewController *toViewController;
}
@property (nonatomic) BOOL presenting;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, readonly) CGSize screenSize;
@property (nullable, nonatomic, readonly) UIViewController *belowViewController;
@property (nullable, nonatomic, readonly) UIViewController *aboveViewController;
- (NSTimeInterval)currentDuration:(id<UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
@end
