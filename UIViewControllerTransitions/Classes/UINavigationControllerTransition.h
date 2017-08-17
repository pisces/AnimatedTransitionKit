//
//  UINavigationControllerTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//
//

#import <UIKit/UIKit.h>
#import "AnimatedNavigationTransitioning.h"
#import "UIViewControllerAnimatedTransition.h"

@protocol UINavigationControllerTransitionProtected <NSObject>
- (AnimatedNavigationTransitioning * _Nullable)transitioningForPop;
- (AnimatedNavigationTransitioning * _Nullable)transitioningForPush;
@end

@interface UINavigationControllerTransition : UIViewControllerAnimatedTransition <UINavigationControllerDelegate, UINavigationControllerTransitionProtected>
@property (nonatomic) NSTimeInterval durationForPop;
@property (nonatomic) NSTimeInterval durationForPush;
@property (nonatomic) UIViewAnimationOptions animationOptionsForPop;
@property (nonatomic) UIViewAnimationOptions animationOptionsForPush;
@property (nonnull, nonatomic, strong) AbstractInteractiveTransition *interactor;
@property (nullable, nonatomic, weak) UINavigationController *navigationController;
@end

@interface UINavigationController (UIViewControllerTransitions)
@property (nullable, nonatomic, weak) UINavigationControllerTransition *navigationTransition;
@end
