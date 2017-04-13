//
//  AbstractUIViewControllerTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//
//

#import <UIKit/UIKit.h>
#import "AnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"

@protocol AbstractUIViewControllerTransitionProtected <NSObject>
- (AnimatedTransitioning * _Nullable)animatedTransitioningForDismissedController:(UIViewController * _Nullable)dismissed;
- (AnimatedTransitioning * _Nullable)animatedTransitioningForForPresentedController:(UIViewController * _Nullable)presented presentingController:(UIViewController * _Nullable)presenting sourceController:(UIViewController * _Nullable)source;
- (void)initProperties;
- (void)interactiveTransitionBegan:(AbstractInteractiveTransition * _Nonnull)interactor;
- (void)interactiveTransitionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
- (void)interactiveTransitionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent;
- (void)interactiveTransitionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion;
@end

@protocol UIViewControllerTransitionDataSource;
@protocol UIViewControllerTransitionDelegate;

@interface AbstractUIViewControllerTransition : NSObject <AbstractUIViewControllerTransitionProtected, UIViewControllerTransitioningDelegate>
@property (nonatomic, getter=isAllowsInteraction) BOOL allowsInteraction;
@property (nonatomic, getter=isInteractionEnabled) BOOL interactionEnabled;
@property (nonatomic) CGFloat bounceHeight;
@property (nonatomic) NSTimeInterval durationForDismission;
@property (nonatomic) NSTimeInterval durationForPresenting;
@property (nullable, nonatomic, weak) UIViewController *viewController;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *dismissionInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *presentingInteractor;
@property (nullable, nonatomic, weak) id<UIViewControllerTransitionDataSource> dismissionDataSource;
@property (nullable, nonatomic, weak) id<UIViewControllerTransitionDelegate> dismissionDelegate;
- (id _Nonnull)initWithViewController:(__weak UIViewController * _Nullable)viewController;
- (void)dismiss;
@end

@protocol UIViewControllerTransitionDataSource <NSObject>
@optional
- (BOOL)shouldReceiveTouchWithGestureRecognizer:(UIGestureRecognizer * _Nullable)gestureRecognizer touch:(UITouch * _Nullable)touch;
- (BOOL)shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer * _Nonnull)otherGestureRecognizer;
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
