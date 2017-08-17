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
//

#import <UIKit/UIKit.h>
#import "UIViewControllerAnimatedTransition.h"
#import "AnimatedTransitioning.h"

@protocol UIViewControllerTransitionProtected <NSObject>
- (AnimatedTransitioning * _Nullable)transitioningForDismissedController:(UIViewController * _Nullable)dismissed;
- (AnimatedTransitioning * _Nullable)transitioningForForPresentedController:(UIViewController * _Nullable)presented presentingController:(UIViewController * _Nullable)presenting sourceController:(UIViewController * _Nullable)source;
@end

@interface UIViewControllerTransition : UIViewControllerAnimatedTransition <UIViewControllerTransitioningDelegate, UIViewControllerTransitionProtected>
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
