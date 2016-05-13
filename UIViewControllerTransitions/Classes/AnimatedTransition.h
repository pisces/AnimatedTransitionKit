//
//  AnimatedTransition.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import <UIKit/UIKit.h>

@protocol AnimatedTransitionProtected <NSObject>
- (void)animateTransitionForDismission:(id <UIViewControllerContextTransitioning>)transitionContext;
- (void)animateTransitionForPresenting:(id <UIViewControllerContextTransitioning>)transitionContext;
@end

@interface AnimatedTransition : NSObject <AnimatedTransitionProtected, UIViewControllerAnimatedTransitioning>
{
@protected
    UIViewController *fromViewController;
    UIViewController *toViewController;
}
@property (nonatomic) BOOL presenting;
@end
