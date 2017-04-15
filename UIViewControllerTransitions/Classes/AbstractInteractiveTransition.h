//
//  AbstractInteractiveTransition.h
//  UIViewControllerTransitions
//
//  Created by pisces on 13/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InteractiveTransitionDirection) {
    InteractiveTransitionDirectionVertical,
    InteractiveTransitionDirectionHorizontal
};

@protocol InteractiveTransitionDataSource;
@protocol InteractiveTransitionDelegate;

@interface AbstractInteractiveTransition : UIPercentDrivenInteractiveTransition <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) BOOL shouldComplete;
@property (nonatomic) InteractiveTransitionDirection direction;
@property (nonatomic) CGPoint beginPoint;
@property (nonatomic) CGPoint beginViewPoint;
@property (nonatomic) CGPoint point;
@property (nullable, nonatomic, weak) id<InteractiveTransitionDelegate> delegate;
@property (nonnull, nonatomic, readonly) UIGestureRecognizer *gestureRecognizer;
@property (nullable, readonly) UIViewController *presentViewController;
@property (nonnull, readonly) UIViewController *viewController;
@property (nonnull, readonly) UIViewController *currentViewController;
- (void)attach:(__weak UIViewController * _Nonnull)viewController presentViewController:(__weak UIViewController * _Nullable)presentViewController;
- (void)detach;
@end

@protocol InteractiveTransitionDelegate <NSObject>
@optional
- (void)didBeginWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didChangeWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)didCancelWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didCompleteWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor shouldReceiveTouchWithGestureRecognizer:(UIGestureRecognizer * _Nullable)gestureRecognizer touch:(UITouch * _Nullable)touch;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
@end
