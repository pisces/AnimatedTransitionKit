//
//  AnimatedNavigationTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//
//

#import <UIKit/UIKit.h>
#import "AbstractAnimatedTransitioning.h"

@protocol AnimatedNavigationTransitioningProtected <NSObject>
- (void)animateTransitionForPop:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)animateTransitionForPush:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
@end

@interface AnimatedNavigationTransitioning : AbstractAnimatedTransitioning <AnimatedNavigationTransitioningProtected>
@property (nonatomic, getter=isPush) BOOL push;
@end
