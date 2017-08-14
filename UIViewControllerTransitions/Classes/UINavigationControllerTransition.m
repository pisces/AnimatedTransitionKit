//
//  AbstractUINavigationControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//
//

#import "UINavigationControllerTransition.h"
#import "PanningInteractiveTransition.h"
#import <objc/runtime.h>

@implementation UINavigationControllerTransition
@synthesize transitioning = _transitioning;

#pragma mark - Overridden: UIViewControllerAnimatedTransition

- (AbstractInteractiveTransition *)currentInteractor {
    if (!self.allowsInteraction || !self.interactionEnabled) {
        return nil;
    }
    return ((AnimatedNavigationTransitioning *) self.transitioning).isPush ? nil : self.dismissionInteractor;
}

- (void)setNavigationController:(UINavigationController *)navigationController {
    if ([navigationController isEqual:_navigationController]) {
        return;
    }
    
    _navigationController = navigationController;
    _navigationController.delegate = self;
    
    [self.dismissionInteractor attach:_navigationController];
}

- (void)initProperties {
    [super initProperties];
    
    self.allowsInteraction = true;
    self.dismissionInteractor.direction = InteractiveTransitionDirectionHorizontal;
    _durationForPop = _durationForPush = 0.25;
    _animationOptionsForPop = _animationOptionsForPush = 7<<16;
}

#pragma mark - UINavigationController delegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    BOOL isPush = operation == UINavigationControllerOperationPush;
    AnimatedNavigationTransitioning *transitioning = isPush ? [self transitioningForPush] : [self transitioningForPop];
    transitioning.push = isPush;
    transitioning.animationOptions = isPush ? _animationOptionsForPush : _animationOptionsForPop;
    transitioning.duration = isPush ? _durationForPush : _durationForPop;
    _transitioning = transitioning;
    return _transitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                      interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController {
    return self.currentInteractor;
}

#pragma mark - Protected methods

- (AnimatedNavigationTransitioning *)transitioningForPop {
    return nil;
}

- (AnimatedNavigationTransitioning *)transitioningForPush {
    return nil;
}

@end

static void *AssociatedKeyNavigationTransition = @"navigationTransition";

@implementation UINavigationController (UIViewControllerTransitions)

- (void)setNavigationTransition:(UINavigationControllerTransition *)navigationTransition {
    if ([navigationTransition isEqual:[self navigationTransition]])
        return;
    
    navigationTransition.navigationController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyNavigationTransition, navigationTransition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationControllerTransition *)navigationTransition {
    return objc_getAssociatedObject(self, &AssociatedKeyNavigationTransition);
}

@end
