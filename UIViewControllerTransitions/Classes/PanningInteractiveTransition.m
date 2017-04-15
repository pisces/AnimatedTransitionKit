//
//  PanningInteractiveTransition.m
//  UIViewControllerTransitions
//
//  Created by pisces on 11/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import "PanningInteractiveTransition.h"
#import "AbstractUIViewControllerTransition.h"

@interface PanningInteractiveTransition ()
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation PanningInteractiveTransition

@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize shouldComplete = _shouldComplete;

#pragma mark - Properties

- (UIPanGestureRecognizer *)panGestureRecognizer {
    return (UIPanGestureRecognizer *) _gestureRecognizer;
}

#pragma mark - Con(De)structor

- (void)dealloc {
    [_gestureRecognizer removeTarget:self action:@selector(panned)];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned)];
        _gestureRecognizer.delegate = self;
    }
    
    return self;
}

#pragma mark - Overridden: AbstractInteractiveTransition

- (void)attach:(UIViewController *)viewController presentViewController:(UIViewController *)presentViewController {
    [super attach:viewController presentViewController:presentViewController];
    
    [self.viewController.view addGestureRecognizer:_gestureRecognizer];
}

- (void)detach {
    [self.viewController.view removeGestureRecognizer:_gestureRecognizer];
    
    [super detach];
}

#pragma mark - Private selector

- (void)panned {
    const AbstractUIViewControllerTransition *transition = self.currentViewController.transition;
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.window];
    const BOOL isDismissing = self.presentViewController == nil;
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.beginPoint = newPoint;
            transition.interactionEnabled = YES;
            
            if (isDismissing) {
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [transition interactiveTransitionBegan:self];
                
                if ([self.delegate respondsToSelector:@selector(didBeginWithInteractor:)]) {
                    [self.delegate didBeginWithInteractor:self];
                }
            });
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!transition.interactionEnabled) {
                return;
            }
            
            const CGPoint translation = [self.panGestureRecognizer translationInView:self.currentViewController.view.window];
            const CGFloat targetSize = self.direction == InteractiveTransitionDirectionVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat point = self.direction == InteractiveTransitionDirectionVertical ? translation.y : translation.x;
            const CGFloat dragAmount = targetSize * (self.presentViewController ? -1 : 1);
            const CGFloat threshold = transition.bounceHeight / targetSize;
            const CGFloat percent = fmin(fmax(point / dragAmount, 0), 1);
            _shouldComplete = ABS(point / dragAmount) > threshold;
            self.point = newPoint;
            
            if (CGPointEqualToPoint(self.beginViewPoint, CGPointZero)) {
                self.beginViewPoint = self.currentViewController.view.frame.origin;
            }
            
            [self updateInteractiveTransition:percent];
            [transition interactiveTransitionChanged:self percent:percent];
            
            if ([self.delegate respondsToSelector:@selector(didChangeWithInteractor:percent:)]) {
                [self.delegate didChangeWithInteractor:self percent:percent];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!transition.interactionEnabled) {
                return;
            }
            
            void (^completion)(void) = ^void(void) {
                if (_shouldComplete) {
                    if ([self.delegate respondsToSelector:@selector(didCompleteWithInteractor:)]) {
                        [self.delegate didCompleteWithInteractor:self];
                    }
                } else {
                    if ([self.delegate respondsToSelector:@selector(didCancelWithInteractor:)]) {
                        [self.delegate didCancelWithInteractor:self];
                    }
                }
                
                transition.interactionEnabled = NO;
                self.beginPoint = CGPointZero;
                self.beginViewPoint = CGPointZero;
                self.point = CGPointZero;
            };
            
            if (_gestureRecognizer.state == UIGestureRecognizerStateCancelled || !_shouldComplete) {
                [self cancelInteractiveTransition];
                [transition interactiveTransitionCancelled:self completion:completion];
            } else {
                [self finishInteractiveTransition];
                [transition interactiveTransitionCompleted:self completion:completion];
            }
            break;
        }
        default:
            break;
    }
}

@end
