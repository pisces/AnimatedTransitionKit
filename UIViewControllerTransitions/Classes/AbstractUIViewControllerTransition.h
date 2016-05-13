//
//  AbstractUIViewControllerTransition.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import <UIKit/UIKit.h>

@protocol AbstractUIViewControllerTransitionProtected <NSObject>
- (void)animateTransitionBegan:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionCancelled:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionChanged:(UIPanGestureRecognizer * _Nonnull)gestureRecognizer;
- (void)animateTransitionCancelCompleted;
@end

@protocol UIViewControllerTransitionDataSource;
@protocol UIViewControllerTransitionDelegate;

@interface AbstractUIViewControllerTransition : NSObject <AbstractUIViewControllerTransitionProtected, UIViewControllerTransitioningDelegate>
{
@protected
    CGPoint originPoint;
    CGPoint originViewPoint;
}

@property (nonatomic) BOOL allowsGestureTransitions;
@property (nonatomic) CGFloat bounceHeight;
@property (nonatomic, strong) UIViewController * _Nullable viewController;
@property (nonatomic, weak) id<UIViewControllerTransitionDataSource> _Nullable dismissionDataSource;
@property (nonatomic, weak) id<UIViewControllerTransitionDelegate> _Nullable dismissionDelegate;
- (id _Nonnull)initWithViewController:(UIViewController * _Nullable)viewController;
@end

@protocol UIViewControllerTransitionDataSource <NSObject>
@optional
- (BOOL)shouldRequireTransitionFailure;
@end

@protocol UIViewControllerTransitionDelegate <NSObject>
@optional
- (void)didBeginTransition;
- (void)didEndTransition;
@end

@interface UIViewController (UIViewControllerTransitions)
@property (nullable, nonatomic, strong) AbstractUIViewControllerTransition *transition;
@end