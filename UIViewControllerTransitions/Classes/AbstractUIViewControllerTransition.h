//
//  AbstractUIViewControllerTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import <UIKit/UIKit.h>
#import "AnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"

@protocol AbstractUIViewControllerTransitionProtected <NSObject>
- (AnimatedTransitioning * _Nullable)animatedTransitioningForDismissedController:(UIViewController * _Nullable)dismissed;
- (AnimatedTransitioning * _Nullable)animatedTransitioningForForPresentedController:(UIViewController * _Nullable)presented presentingController:(UIViewController * _Nullable)presenting sourceController:(UIViewController * _Nullable)source;
- (void)initProperties;
@end

@interface AbstractUIViewControllerTransition : NSObject <AbstractUIViewControllerTransitionProtected, UIViewControllerTransitioningDelegate>
@property (nonatomic, getter=isAllowsInteraction) BOOL allowsInteraction;
@property (nonatomic, getter=isInteractionEnabled) BOOL interactionEnabled;
@property (nonatomic) CGFloat bounceHeight;
@property (nonatomic) UIViewAnimationOptions animationOptionsForDismission;
@property (nonatomic) UIViewAnimationOptions animationOptionsForPresenting;
@property (nonatomic) NSTimeInterval durationForDismission;
@property (nonatomic) NSTimeInterval durationForPresenting;
@property (nullable, nonatomic, weak) UIViewController *viewController;
@property (nullable, nonatomic, readonly) AnimatedTransitioning *transitioning;
@property (nullable, nonatomic, readonly) AbstractInteractiveTransition *currentInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *dismissionInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *presentingInteractor;
- (void)dismiss;
- (id _Nonnull)initWithViewController:(__weak UIViewController * _Nullable)viewController;
@end

@interface UIViewController (UIViewControllerTransitions)
@property (nullable, nonatomic) AbstractUIViewControllerTransition *transition;
@end
