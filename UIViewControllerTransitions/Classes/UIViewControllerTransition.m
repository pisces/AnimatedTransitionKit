//
//  AbstractUIViewControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//
//

#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"
#import "PanningInteractiveTransition.h"
#import <objc/runtime.h>

@interface UIViewControllerTransition () <UIGestureRecognizerDelegate>
@end

@implementation UIViewControllerTransition
@synthesize currentInteractor = _currentInteractor;
@synthesize transitioning = _transitioning;

#pragma mark - Overridden: UIViewControllerAnimatedTransition

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    [super setAllowsInteraction:allowsInteraction];
    
    _dismissionInteractor.gestureRecognizer.enabled = allowsInteraction;
    _presentingInteractor.gestureRecognizer.enabled = allowsInteraction;
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController]) {
        return;
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [self.dismissionInteractor attach:_viewController presentViewController:nil];
}

- (void)initProperties {
    [super initProperties];
    
    _animationOptionsForDismission = _animationOptionsForPresenting = 7<<16;
    _durationForDismission = _durationForPresenting = 0.6;
    _dismissionInteractor = [PanningInteractiveTransition new];
    _presentingInteractor = [PanningInteractiveTransition new];
}

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _currentInteractor = self.dismissionInteractor;
    _transitioning = [self transitioningForDismissedController:dismissed];
    _transitioning.animationOptions = _animationOptionsForDismission;
    _transitioning.duration = _durationForDismission;
    return _transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _currentInteractor = self.presentingInteractor;
    _transitioning = [self transitioningForForPresentedController:presented presentingController:presenting sourceController:source];
    ((AnimatedTransitioning *) _transitioning).presenting = YES;
    _transitioning.animationOptions = _animationOptionsForPresenting;
    _transitioning.duration = _durationForPresenting;
    return _transitioning;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.interactionEnabled) ? self.dismissionInteractor : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (self.allowsInteraction && self.interactionEnabled) ? self.presentingInteractor : nil;
}

#pragma mark - Protected methods

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return nil;
}

@end

static void *AssociatedKeyTransition = @"transition";

@implementation UIViewController (UIViewControllerTransitions)

- (void)setTransition:(UIViewControllerTransition *)transition {
    if ([transition isEqual:[self transition]])
        return;
    
    transition.viewController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, &AssociatedKeyTransition);
}

@end
