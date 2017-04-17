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

@class AbstractUIViewControllerTransition;

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
@property (nonnull, nonatomic, readonly) UIGestureRecognizer *gestureRecognizer;
@property (nullable, nonatomic, weak) id<InteractiveTransitionDelegate> delegate;
@property (nullable, readonly) UIViewController *presentViewController;
@property (nonnull, readonly) UIViewController *viewController;
@property (nonnull, readonly) UIViewController *currentViewController;
@property (nullable, nonatomic, readonly) AbstractUIViewControllerTransition *transition;
- (void)attach:(__weak UIViewController * _Nonnull)viewController presentViewController:(__weak UIViewController * _Nullable)presentViewController;
- (void)detach;
@end

@protocol InteractiveTransitionDelegate <NSObject>
@optional
- (void)didBeginWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didChangeWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)didCancelWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)didCompleteWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizerShouldBegin:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldReceiveTouch:(UITouch * _Nullable)touch;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor gestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
- (BOOL)interactor:(AbstractInteractiveTransition * _Nonnull)interactor shouldInteractionWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)gestureRecognizer;
@end
