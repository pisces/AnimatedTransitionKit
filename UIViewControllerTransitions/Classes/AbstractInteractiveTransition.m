//
//  AbstractInteractiveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 13/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import "AbstractInteractiveTransition.h"
#import "UIViewControllerTransitions.h"

@implementation AbstractInteractiveTransition

#pragma mark - Properties

- (BOOL)isAppearing {
    return _presentViewController != nil;
}

- (UIViewController *)currentViewController {
    return self.isAppearing ? _presentViewController : _viewController;
}

- (UIViewControllerAnimatedTransition *)transition {
    return self.currentViewController.transition;
}

#pragma mark - Con(De)structor

- (id)init {
    self = [super init];
    if (self) {
        _direction = InteractiveTransitionDirectionVertical;
    }
    return self;
}

#pragma mark - Overridden: UIPercentDrivenInteractiveTransition

- (void)cancelInteractiveTransition {
    [super cancelInteractiveTransition];
    
    if ([_delegate respondsToSelector:@selector(willCancelWithInteractor:)]) {
        [_delegate willCancelWithInteractor:self];
    }
    
    [self.transition.transitioning interactionCancelled:self completion:^{
        [self completion];
    }];
}

- (void)finishInteractiveTransition {
    [super finishInteractiveTransition];
    
    if ([_delegate respondsToSelector:@selector(willCompleteWithInteractor:)]) {
        [_delegate willCompleteWithInteractor:self];
    }
    
    [self.transition.transitioning interactionCompleted:self completion:^{
        [self completion];
    }];
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];
    
    [self.transition.transitioning startAnimating];
    [self.transition.transitioning interactionBegan:self transitionContext:transitionContext];
    
    if ([_delegate respondsToSelector:@selector(didBeginWithInteractor:)]) {
        [_delegate didBeginWithInteractor:self];
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];
    
    [self.transition.transitioning interactionChanged:self percent:percentComplete];
    
    if ([_delegate respondsToSelector:@selector(didChangeWithInteractor:percent:)]) {
        [_delegate didChangeWithInteractor:self percent:percentComplete];
    }
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizerShouldBegin:)]) {
        return [_delegate interactor:self gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldReceiveTouch:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - Public methods

- (void)attach:(UIViewController *)viewController presentViewController:(UIViewController *)presentViewController {
    [self detach];
    
    _viewController = viewController;
    _presentViewController = presentViewController;
    
    [_viewController.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)detach {
    [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
    
    _viewController = nil;
    _presentViewController = nil;
}

#pragma mark - Private methods

- (void)completion {
    [self.transition.transitioning endAnimating];
    
    if (self.shouldComplete) {
        if ([_delegate respondsToSelector:@selector(didCompleteWithInteractor:)]) {
            [_delegate didCompleteWithInteractor:self];
        }
    } else {
        if ([_delegate respondsToSelector:@selector(didCancelWithInteractor:)]) {
            [_delegate didCancelWithInteractor:self];
        }
    }
    
    _beginPoint = CGPointZero;
    _beginViewPoint = CGPointZero;
    _point = CGPointZero;
}

@end
