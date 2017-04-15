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

@implementation AbstractInteractiveTransition

#pragma mark - Properties

- (UIViewController *)currentViewController {
    return _presentViewController ? _presentViewController : _viewController;
}

#pragma mark - Con(De)structor

- (id)init {
    self = [super init];
    
    if (self) {
        _direction = InteractiveTransitionDirectionVertical;
    }
    
    return self;
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([_delegate respondsToSelector:@selector(shouldReceiveTouchWithGestureRecognizer:touch:)]) {
        return [_delegate shouldReceiveTouchWithGestureRecognizer:gestureRecognizer touch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [_delegate shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - Public methods

- (void)attach:(UIViewController *)viewController presentViewController:(UIViewController *)presentViewController {
    [self detach];
    
    _viewController = viewController;
    _presentViewController = presentViewController;
}

- (void)detach {
    _viewController = nil;
    _presentViewController = nil;
}

@end
