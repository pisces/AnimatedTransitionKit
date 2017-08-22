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

const CGFloat unfocusedCompletionBounds = 50;

@implementation NavigationMoveTransitioning
@synthesize percentOfBounds = _percentOfBounds;

#pragma mark - Overridden: AnimatedNavigationTransitioning

- (CGFloat)completionBounds {
    return 60 * self.widthRatio;
}

- (void)animateTransitionForPop:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.transform = self.focusedTransformFrom;
    self.toViewController.view.transform = self.unfocusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [transitionContext.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.transform = self.focusedTransformTo;
            self.toViewController.view.transform = self.unfocusedTransformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            
            dispatch_after_sec(0.05, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)animateTransitionForPush:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.transform = self.unfocusedTransformFrom;
    self.toViewController.view.transform = self.focusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [transitionContext.containerView addSubview:self.toViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.transform = self.unfocusedTransformTo;
            self.toViewController.view.transform = self.focusedTransformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            
            dispatch_after_sec(0.05, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    self.aboveViewController.view.transform = self.focusedTransformFrom;
    self.belowViewController.view.transform = self.unfocusedTransformFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.focusedTransformFrom;
        self.belowViewController.view.transform = self.unfocusedTransformFrom;
    } completion:^(BOOL finished) {
        self.belowViewController.view.hidden = !self.isPush;
        
        dispatch_after_sec(0.05, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    const CGFloat x = self.focusedTransformFrom.tx + ((interactor.point.x - interactor.beginPoint.x) * 1.2);
    self.aboveViewController.view.transform = CGAffineTransformMakeTranslation(MAX(0, x), 0);
    self.belowViewController.view.transform = self.unfocusedTransform;
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.transform = self.focusedTransformTo;
        self.belowViewController.view.transform = self.unfocusedTransformTo;
    } completion:^(BOOL finished) {
        self.belowViewController.view.hidden = self.isPush;
        
        dispatch_after_sec(0.05, ^{
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        });
    }];
}

#pragma mark - Properties

- (void)updatePercentOfBounds {
    _percentOfBounds = self.percentOfInteraction * (UIScreen.mainScreen.bounds.size.width / self.completionBounds);
}

- (CGAffineTransform)focusedTransformFrom {
    return CGAffineTransformMakeTranslation(self.isPush ? UIScreen.mainScreen.bounds.size.width : 0, 0);
}

- (CGAffineTransform)focusedTransformTo {
    return CGAffineTransformMakeTranslation(self.isPush ? 0 : UIScreen.mainScreen.bounds.size.width, 0);
}

- (CGAffineTransform)unfocusedTransform {
    CGFloat x = self.isPush ? -unfocusedCompletionBounds * self.percentOfInteraction : -(unfocusedCompletionBounds - (unfocusedCompletionBounds * self.percentOfInteraction));
    return CGAffineTransformMakeTranslation(MIN(0, MAX(-unfocusedCompletionBounds, x)), 0);
}

- (CGAffineTransform)unfocusedTransformFrom {
    return CGAffineTransformMakeTranslation(self.isPush ? 0 : -unfocusedCompletionBounds, 0);
}

- (CGAffineTransform)unfocusedTransformTo {
    return CGAffineTransformMakeTranslation(self.isPush ? -unfocusedCompletionBounds : 0, 0);
}

@end
