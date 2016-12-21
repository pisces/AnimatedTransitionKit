//
//  AbstractUIViewControllerTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "AbstractUIViewControllerTransition.h"
#import "AnimatedTransition.h"
#import "UIViewControllerTransitionsMacro.h"
#import <objc/runtime.h>

@implementation AbstractUIViewControllerTransition
{
    BOOL keyboardShowing;
    __weak UIViewController *presentedController;
    __weak UIViewController *sourceController;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc {
    [self dismiss];
    [_viewController.view removeGestureRecognizer:_panGestureRecognizer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initProperties];
    }
    
    return self;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public methods

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    
    if (self) {
        [self initProperties];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        
        _viewController = viewController;
    }
    
    return self;
}

- (void)dismiss {
    [presentedController.navigationController viewWillDisappear:NO];
    [sourceController.navigationController viewWillAppear:NO];
    
    presentedController.navigationController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
    [presentedController.navigationController.view removeFromSuperview];
    
    sourceController.navigationController.view.alpha = 1;
    sourceController.navigationController.view.hidden = NO;
    sourceController.navigationController.view.userInteractionEnabled = YES;
    sourceController.navigationController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    sourceController.navigationController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    [presentedController.navigationController viewDidDisappear:NO];
    [sourceController.navigationController viewDidAppear:NO];
    
    self.statusBarWindow.frame = CGRectMakeY(self.statusBarWindow.frame, 0);
}

- (UIWindow *)statusBarWindow {
    return [[UIApplication sharedApplication] valueForKey:@"statusBarWindow"];
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UIViewControllerTransitioning delegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self animatedTransitionForDismissedController:dismissed];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    presentedController = presented;
    sourceController = source;
    return [self animatedTransitionForForPresentedController:presented presentingController:presenting sourceController:source];
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController])
        return;
    
    if (_viewController) {
        [_viewController.view removeGestureRecognizer:_panGestureRecognizer];
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_viewController.view addGestureRecognizer:_panGestureRecognizer];
}

// ================================================================================================
//  Protected
// ================================================================================================

#pragma mark - Protected methods

- (AnimatedTransition *)animatedTransitionForDismissedController:(UIViewController *)dismissed {
    return nil;
}

- (AnimatedTransition *)animatedTransitionForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return nil;
}

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionCancelled:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionCancelCompleted {
}

// ================================================================================================
//  Protected
// ================================================================================================

#pragma mark - Protected methods

- (void)initProperties {
    _allowsGestureTransitions = YES;
    _bounceHeight = 100;
    _durationForDismission = _durationForPresenting = 0.6;
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - UIGestureRecognizer selector

- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!_allowsGestureTransitions)
        return;
    
    if (gestureRecognizer.numberOfTouches > 1 ||
        keyboardShowing ||
        ([_dismissionDataSource respondsToSelector:@selector(shouldRequireTransitionFailure)] && [_dismissionDataSource shouldRequireTransitionFailure]))
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _originPoint = [gestureRecognizer locationInView:_viewController.view.window];
        _originViewPoint = _viewController.view.frame.origin;
        
        [self animateTransitionBegan:gestureRecognizer];
        [_dismissionDelegate didBeginTransition];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self animateTransitionChanged:gestureRecognizer];
        [_dismissionDelegate didChangeTransition];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint p = [gestureRecognizer locationInView:_viewController.view.window];
        CGFloat y = _originViewPoint.y + (p.y - _originPoint.y);
        
        if (ABS(y) > _bounceHeight) {
            [_viewController dismissViewControllerAnimated:YES completion:^{
                [_dismissionDelegate didEndTransition];
            }];
        } else {
            [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
                [self animateTransitionCancelled:gestureRecognizer];
            } completion:^(BOOL finished) {
                [self animateTransitionCancelCompleted];
                [_dismissionDelegate didEndTransition];
            }];
        }
    }
}

#pragma mark - Notification selector

- (void)keyboardWillShow:(NSNotification *)notification {
    keyboardShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    keyboardShowing = NO;
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
