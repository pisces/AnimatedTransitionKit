//
//  AbstractUIViewControllerTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "AbstractUIViewControllerTransition.h"
#import <objc/runtime.h>

@implementation AbstractUIViewControllerTransition
{
    BOOL keyboardShowing;
    UIPanGestureRecognizer *panGestureRecognizer;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc {
    [_viewController.view removeGestureRecognizer:panGestureRecognizer];
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
        
        self.viewController = viewController;
    }
    
    return self;
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UIViewControllerTransitioning delegate

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
}

- (void)setViewController:(UIViewController *)viewController {
    if ([viewController isEqual:_viewController])
        return;
    
    if (_viewController) {
        [_viewController.view removeGestureRecognizer:panGestureRecognizer];
    }
    
    _viewController = viewController;
    _viewController.transitioningDelegate = self;
    _viewController.modalPresentationStyle = UIModalPresentationCustom;
    
    [_viewController.view addGestureRecognizer:panGestureRecognizer];
}

// ================================================================================================
//  Protected
// ================================================================================================

#pragma mark - Protected methods

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionCancelled:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
}

- (void)animateTransitionCancelCompleted {
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)initProperties {
    _allowsGestureTransitions = YES;
    _bounceHeight = 100;
    panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
}

#pragma mark -  UIGestureRecognizer selector

- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer {
    if (!_allowsGestureTransitions)
        return;
    
    if (gestureRecognizer.numberOfTouches > 1 ||
        keyboardShowing ||
        ([_dismissionDataSource respondsToSelector:@selector(shouldRequireTransitionFailure)] && ![_dismissionDataSource shouldRequireTransitionFailure]))
        return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        originPoint = [gestureRecognizer locationInView:_viewController.view.window];
        originViewPoint = _viewController.view.frame.origin;
        
        [self animateTransitionBegan:gestureRecognizer];
        [_dismissionDelegate didBeginTransition];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        [self animateTransitionChanged:gestureRecognizer];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
               gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint p = [gestureRecognizer locationInView:_viewController.view.window];
        CGFloat y = originViewPoint.y + (p.y - originPoint.y);
        
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