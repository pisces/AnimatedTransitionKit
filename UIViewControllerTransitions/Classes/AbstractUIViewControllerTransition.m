//
//  AbstractUIViewControllerTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
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
{
    AnimatedTransitioning *dismissTransitioning;
    AnimatedTransitioning *presentTransitioning;
}

#pragma mark - Overridden: NSObject

- (void)dealloc {
    [self dismiss];
    
    
    
    
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initProperties];
    }
    
    return self;
}

#pragma mark - Properties

- (void)setDismissionInteractor:(AbstractInteractiveTransition *)dismissionInteractor {
    if ([dismissionInteractor isEqual:_dismissionInteractor]) {
        return;
    }
    
    _dismissionInteractor = dismissionInteractor;
    
    if ([dismissionInteractor isKindOfClass:[PanningInteractiveTransition class]]) {
        ((PanningInteractiveTransition *) dismissionInteractor).panGestureRecognizer.delegate = self;
    }
}

- (void)setPresentingInteractor:(AbstractInteractiveTransition *)presentingInteractor {
    if ([presentingInteractor isEqual:_presentingInteractor]) {
        return;
    }
    
    _presentingInteractor = presentingInteractor;
    
    if ([presentingInteractor isKindOfClass:[PanningInteractiveTransition class]]) {
        ((PanningInteractiveTransition *) presentingInteractor).panGestureRecognizer.delegate = self;
    }
}

#pragma mark - Public methods

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        [self initProperties];
        
        _viewController = viewController;
    }
    
    return self;
}

- (void)dismiss {
}

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self clear];
    
    dismissTransitioning = [self animatedTransitioningForDismissedController:dismissed];
    return dismissTransitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    [self clear];
    
    presentTransitioning = [self animatedTransitioningForForPresentedController:presented presentingController:presenting sourceController:source];
    return presentTransitioning;
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
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (!_allowsInteraction) {
        return NO;
    }
    
    if ([self.dismissionDataSource respondsToSelector:@selector(shouldReceiveTouchWithGestureRecognizer:touch:)]) {
        return [self.dismissionDataSource shouldReceiveTouchWithGestureRecognizer:gestureRecognizer touch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (!_allowsInteraction) {
        return NO;
    }
    
    if ([self.dismissionDataSource respondsToSelector:@selector(shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [self.dismissionDataSource shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - Public methods

- (void)interactiveTransitionBegan:(AbstractInteractiveTransition * _Nonnull)interactor {
    if ([interactor isEqual:_presentingInteractor]) {
        [presentTransitioning interactionBegan:interactor];
    } else if ([interactor isEqual:_dismissionInteractor]) {
        [dismissTransitioning interactionBegan:interactor];
    }
}

- (void)interactiveTransitionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor  completion:(void (^_Nullable)(void))completion {
    if ([interactor isEqual:_presentingInteractor]) {
        [presentTransitioning interactionCancelled:interactor completion:completion];
    } else if ([interactor isEqual:_dismissionInteractor]) {
        [dismissTransitioning interactionCancelled:interactor completion:completion];
    }
}

- (void)interactiveTransitionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    if ([interactor isEqual:_presentingInteractor]) {
        [presentTransitioning interactionChanged:interactor percent:percent];
    } else if ([interactor isEqual:_dismissionInteractor]) {
        [dismissTransitioning interactionChanged:interactor percent:percent];
    }
}

- (void)interactiveTransitionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    if ([interactor isEqual:_presentingInteractor]) {
        [presentTransitioning interactionCompleted:interactor completion:completion];
    } else if ([interactor isEqual:_dismissionInteractor]) {
        [dismissTransitioning interactionCompleted:interactor completion:completion];
        [self clear];
    }
}

#pragma mark - Protected methods

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return nil;
}

- (void)initProperties {
    _bounceHeight = 100;
    _durationForDismission = _durationForPresenting = 0.6;
    self.dismissionInteractor = [PanningInteractiveTransition new];
    self.presentingInteractor = [PanningInteractiveTransition new];
}

#pragma mark - Private methods

- (void)clear {
    dismissTransitioning = nil;
    presentTransitioning = nil;
}

@end

@implementation UIViewController (UIViewControllerTransitions)

- (void)setTransition:(AbstractUIViewControllerTransition *)transition {
    if ([transition isEqual:[self transition]])
        return;
    
    transition.viewController = self;
    
    objc_setAssociatedObject(self, @"transition", transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (AbstractUIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, @"transition");
}

@end
