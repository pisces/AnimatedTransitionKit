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
    [self detach];
    [_gestureRecognizer removeTarget:self action:@selector(panned)];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned)];
        _gestureRecognizer.delegate = self;
        _gestureRecognizer.enabled = NO;
    }
    
    return self;
}

#pragma mark - Overridden: AbstractInteractiveTransition

- (void)attach:(UIViewController *)viewController presentViewController:(UIViewController *)presentViewController {
    [super attach:viewController presentViewController:presentViewController];
    
    [self.viewController.view addGestureRecognizer:_gestureRecognizer];
}

- (void)detach {
    [_gestureRecognizer.view removeGestureRecognizer:_gestureRecognizer];
    
    [super detach];
}

#pragma mark - Private selector

- (void)panned {
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    const BOOL isDismissing = self.presentViewController == nil;
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if ([self.delegate respondsToSelector:@selector(interactor:shouldRecognizeSimultaneouslyWithGestureRecognizer:)] &&
                ![self.delegate interactor:self shouldRecognizeSimultaneouslyWithGestureRecognizer:_gestureRecognizer]) {
                return;
            }
            
            self.transition.interactionEnabled = YES;
            self.beginPoint = newPoint;
            self.beginViewPoint = self.currentViewController.view.frame.origin;
            
            if (isDismissing) {
                [self.viewController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transition.interactionEnabled) {
                return;
            }
            
            const CGPoint translation = [self.panGestureRecognizer translationInView:self.currentViewController.view.superview];
            const CGFloat targetSize = self.direction == InteractiveTransitionDirectionVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat point = self.direction == InteractiveTransitionDirectionVertical ? translation.y : translation.x;
            const CGFloat dragAmount = targetSize * (self.presentViewController ? -1 : 1);
            const CGFloat threshold = self.transition.bounceHeight / targetSize;
            const CGFloat percent = fmin(fmax(point / dragAmount, 0), 1);
            self.point = newPoint;
            _shouldComplete = ABS(point / dragAmount) > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.interactionEnabled) {
                return;
            }
            
            if (_gestureRecognizer.state == UIGestureRecognizerStateCancelled || !_shouldComplete) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            
            self.transition.interactionEnabled = NO;
            break;
        }
        default:
            break;
    }
}

@end
