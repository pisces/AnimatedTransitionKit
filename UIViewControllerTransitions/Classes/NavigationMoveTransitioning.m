//
//  NavigationMoveTransitioning.m
//  UIViewControllerTransitions
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

- (void)animateTransitionForPop:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.layer.transform = self.focusedTransformFrom;
    self.toViewController.view.layer.transform = self.unfocusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [self applyDropShadow:self.fromViewController.view.layer];
    [transitionContext.containerView insertSubview:self.toViewController.view belowSubview:self.fromViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.layer.transform = self.focusedTransformTo;
            self.toViewController.view.layer.transform = self.unfocusedTransformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            [self clearDropShadow:self.fromViewController.view.layer];
            
            dispatch_after_sec(0.05, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)animateTransitionForPush:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromViewController.view.layer.transform = self.unfocusedTransformFrom;
    self.toViewController.view.layer.transform = self.focusedTransformFrom;
    self.toViewController.view.hidden = NO;
    
    [self applyDropShadow:self.toViewController.view.layer];
    [transitionContext.containerView addSubview:self.toViewController.view];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.fromViewController.view.layer.transform = self.unfocusedTransformTo;
            self.toViewController.view.layer.transform = self.focusedTransformTo;
        } completion:^(BOOL finished) {
            self.fromViewController.view.hidden = YES;
            [self clearDropShadow:self.toViewController.view.layer];
            
            dispatch_after_sec(0.05, ^{
                [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            });
        }];
    }
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    self.aboveViewController.view.layer.transform = self.focusedTransformFrom;
    self.belowViewController.view.layer.transform = self.unfocusedTransformFrom;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.layer.transform = self.focusedTransformFrom;
        self.belowViewController.view.layer.transform = self.unfocusedTransformFrom;
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
    
    const CGFloat x = CATransform3DGetAffineTransform(self.focusedTransformFrom).tx + ((interactor.point.x - interactor.beginPoint.x) * 1.2);
    self.aboveViewController.view.layer.transform = CATransform3DMakeTranslation(MAX(0, x), 0, 1);
    self.belowViewController.view.layer.transform = self.unfocusedTransform;
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [UIView animateWithDuration:0.15 delay:0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.layer.transform = self.focusedTransformTo;
        self.belowViewController.view.layer.transform = self.unfocusedTransformTo;
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

- (CATransform3D)focusedTransformFrom {
    return CATransform3DMakeTranslation(self.isPush ? UIScreen.mainScreen.bounds.size.width : 0, 0, 1);
}

- (CATransform3D)focusedTransformTo {
    return CATransform3DMakeTranslation(self.isPush ? 0 : UIScreen.mainScreen.bounds.size.width, 0, 1);
}

- (CATransform3D)unfocusedTransform {
    CGFloat x = self.isPush ? -unfocusedCompletionBounds * self.percentOfInteraction : -(unfocusedCompletionBounds - (unfocusedCompletionBounds * self.percentOfInteraction));
    return CATransform3DMakeTranslation(MIN(0, MAX(-unfocusedCompletionBounds, x)), 0, 1);
}

- (CATransform3D)unfocusedTransformFrom {
    return CATransform3DMakeTranslation(self.isPush ? 0 : -unfocusedCompletionBounds, 0, 1);
}

- (CATransform3D)unfocusedTransformTo {
    return CATransform3DMakeTranslation(self.isPush ? -unfocusedCompletionBounds : 0, 0, 1);
}

#pragma mark - Private methods

- (void)applyDropShadow:(CALayer *)layer {
    layer.shouldRasterize = YES;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeMake(-1, -1);
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowRadius = 3;
    layer.shadowOpacity = 0.3;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)clearDropShadow:(CALayer *)layer {
    layer.masksToBounds = YES;
    layer.shouldRasterize = NO;
    layer.shadowOffset = CGSizeZero;
    layer.shadowRadius = 0;
    layer.shadowOpacity = 0;
}

@end

