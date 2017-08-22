//
//  AnimatedTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//

#import <UIKit/UIKit.h>
#import "AbstractAnimatedTransitioning.h"

@protocol AnimatedTransitioningProtected <NSObject>
- (void)animateTransitionForDismission:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
- (void)animateTransitionForPresenting:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext;
@end

@interface AnimatedTransitioning : AbstractAnimatedTransitioning <AnimatedTransitioningProtected>
@property (nonatomic, getter=isPresenting) BOOL presenting;
@end
