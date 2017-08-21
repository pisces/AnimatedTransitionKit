//
//  NavigationMoveTransitioning.m
//  Pods
//
//  Created by pisces on 13/08/2017.
//
//

#import "NavigationMoveTransitioning.h"
#import "PanningInteractiveTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation NavigationMoveTransitioning
@synthesize percentOfBounds = _percentOfBounds;

- (CGAffineTransform)transformFrom {
    return CGAffineTransformMakeTranslation(self.isPush ? UIScreen.mainScreen.bounds.size.width : 0, 0);
}

- (CGAffineTransform)transformTo {
    return CGAffineTransformMakeTranslation(self.isPush ? 0 : UIScreen.mainScreen.bounds.size.width, 0);
}

#pragma mark - Overridden: AnimatedNavigationTransitioning

- (CGFloat)completionBounds {
    return 60 * self.widthRatio;
}

- (void)animateTransitionForPop:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.transform = self.transformFrom;
    self.toViewController.view.hidden = NO;
    
    [transitionContext.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.transform = self.transformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            
            dispatch_after_sec(0.01, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)animateTransitionForPush:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.toViewController.view.transform = self.transformFrom;
    self.toViewController.view.hidden = NO;
    
    [transitionContext.containerView addSubview:self.toViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.toViewController.view.transform = self.transformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            
            dispatch_after_sec(0.01, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    self.aboveViewController.view.transform = self.transformFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.transformFrom;
    } completion:^(BOOL finished) {
        self.belowViewController.view.hidden = !self.isPush;
        
        dispatch_after_sec(0.01, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    const CGFloat x = self.transformFrom.tx + ((interactor.point.x - interactor.beginPoint.x) * 1.5);
    self.aboveViewController.view.transform = CGAffineTransformMakeTranslation(MAX(0, x), 0);
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7<<16 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.transformTo;
    } completion:^(BOOL finished) {
        self.belowViewController.view.hidden = self.isPush;
        
        dispatch_after_sec(0.01, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

- (void)updatePercentOfBounds {
    _percentOfBounds = self.percentOfInteraction * (UIScreen.mainScreen.bounds.size.width / self.completionBounds);
}

@end
