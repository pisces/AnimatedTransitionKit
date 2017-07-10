//
//  AbstractUIViewControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import "AbstractUIViewControllerTransition.h"
#import "AnimatedTransitioning.h"
#import "PanningInteractiveTransition.h"
#import "UIViewControllerTransitionsMacro.h"
#import <objc/runtime.h>

@interface AbstractUIViewControllerTransition () <UIGestureRecognizerDelegate>
@end

@implementation AbstractUIViewControllerTransition

#pragma mark - Con(De)structor

- (void)dealloc {
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initProperties];
    }
    
    return self;
}

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        [self initProperties];
        
        _viewController = viewController;
    }
    
    return self;
}

#pragma mark - Properties

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    if (allowsInteraction == _allowsInteraction) {
        return;
    }
    
    _allowsInteraction = allowsInteraction;
    _dismissionInteractor.gestureRecognizer.enabled = allowsInteraction;
    _presentingInteractor.gestureRecognizer.enabled = allowsInteraction;
}

#pragma mark - Public methods

- (void)dismiss {
    [_transitioning dismiss];
}

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _currentInteractor = _dismissionInteractor;
    _transitioning = [self animatedTransitioningForDismissedController:dismissed];
    _transitioning.animationOptions = _animationOptionsForDismission;
    return _transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _currentInteractor = _presentingInteractor;
    _transitioning = [self animatedTransitioningForForPresentedController:presented presentingController:presenting sourceController:source];
    _transitioning.animationOptions = _animationOptionsForPresenting;
    return _transitioning;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (_allowsInteraction && _interactionEnabled) ? _dismissionInteractor : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return (_allowsInteraction && _interactionEnabled) ? _presentingInteractor : nil;
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController]) {
        return;
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_dismissionInteractor attach:_viewController presentViewController:nil];
}

#pragma mark - Protected methods

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return nil;
}

- (void)initProperties {
    _animationOptionsForDismission = _animationOptionsForPresenting = 7<<16;
    _bounceHeight = 100;
    _durationForDismission = _durationForPresenting = 0.6;
    _dismissionInteractor = [PanningInteractiveTransition new];
    _presentingInteractor = [PanningInteractiveTransition new];
}

@end

static void *AssociatedKeyTransition = @"transition";

@implementation UIViewController (UIViewControllerTransitions)

- (void)setTransition:(AbstractUIViewControllerTransition *)transition {
    if ([transition isEqual:[self transition]])
        return;
    
    __weak AbstractUIViewControllerTransition *weakTransition = transition;
    weakTransition.viewController = self;
    objc_setAssociatedObject(self, &AssociatedKeyTransition, weakTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AbstractUIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, &AssociatedKeyTransition);
}

@end
