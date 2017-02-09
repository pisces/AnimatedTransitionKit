//
//  AbstractUIViewControllerTransition.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import <UIKit/UIKit.h>
#import "AnimatedTransition.h"

@protocol AbstractUIViewControllerTransitionProtected <NSObject>
- (void)animateTransitionBegan:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionCancelled:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionChanged:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionCancelCompleted;
- (AnimatedTransition *)animatedTransitionForDismissedController:(UIViewController *)dismissed;
- (AnimatedTransition *)animatedTransitionForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;
- (void)initProperties;
@end

@protocol UIViewControllerTransitionDataSource;
@protocol UIViewControllerTransitionDelegate;

@interface AbstractUIViewControllerTransition : NSObject <AbstractUIViewControllerTransitionProtected, UIViewControllerTransitioningDelegate>
@property (nonatomic) BOOL allowsGestureTransitions;
@property (nonatomic) CGFloat bounceHeight;
@property (nonatomic) NSTimeInterval durationForDismission;
@property (nonatomic) NSTimeInterval durationForPresenting;
@property (nullable, nonatomic, weak) UIViewController *viewController;
@property (nonatomic, readonly) CGPoint originPoint;
@property (nonatomic, readonly) CGPoint originViewPoint;
@property (nullable, nonatomic, readonly) UIWindow *statusBarWindow;
@property (nullable, nonatomic, weak) id<UIViewControllerTransitionDataSource> dismissionDataSource;
@property (nullable, nonatomic, weak) id<UIViewControllerTransitionDelegate> dismissionDelegate;
@property (nonnull, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
- (id _Nonnull)initWithViewController:(__weak UIViewController * _Nullable)viewController;
- (void)dismiss;
@end

@protocol UIViewControllerTransitionDataSource <NSObject>
@optional
- (BOOL)shouldReceiveTouchWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(UITouch *)touch;
- (BOOL)shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
@end

@protocol UIViewControllerTransitionDelegate <NSObject>
@optional
- (void)didBeginTransition;
- (void)didChangeTransition;
- (void)didEndTransition;
@end

@interface UIViewController (UIViewControllerTransitions)
@property (nullable, nonatomic, weak) AbstractUIViewControllerTransition *transition;
@end
