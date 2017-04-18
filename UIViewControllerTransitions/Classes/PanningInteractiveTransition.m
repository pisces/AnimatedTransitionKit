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
{
    PanningDirection panningDirection;
}

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

#pragma mark - Private methods

- (BOOL)isCompletionDirection {
    BOOL isVertical = self.direction == InteractiveTransitionDirectionVertical;
    CGPoint velocity = [self.panGestureRecognizer velocityInView:self.currentViewController.view.superview];
    CGFloat value = isVertical ? velocity.y : velocity.x;
    
    if (panningDirection == PanningDirectionUp) {return value < 0;}
    if (panningDirection == PanningDirectionDown) {return value > 0;}
    if (panningDirection == PanningDirectionLeft) {return value > 0;}
    if (panningDirection == PanningDirectionRight) {return value < 0;}
    return NO;
}

- (BOOL)isCompletionSpeed {
    BOOL isVertical = self.direction == InteractiveTransitionDirectionVertical;
    CGPoint velocity = [self.panGestureRecognizer velocityInView:self.currentViewController.view.superview];
    CGFloat value = isVertical ? velocity.y : velocity.x;
    CGFloat speed = -1 * value / (isVertical ? (self.beginPoint.y - self.point.y) : (self.beginPoint.x - self.point.x));
    return self.isCompletionDirection && speed > 10;
}

#pragma mark - Private selector

- (void)panned {
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    const BOOL isDismissing = self.presentViewController == nil;
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if ([self.delegate respondsToSelector:@selector(interactor:shouldInteractionWithGestureRecognizer:)] &&
                ![self.delegate interactor:self shouldInteractionWithGestureRecognizer:_gestureRecognizer]) {
                return;
            }
            
            self.transition.interactionEnabled = YES;
            self.beginPoint = newPoint;
            self.beginViewPoint = self.currentViewController.view.frame.origin;
            panningDirection = self.panGestureRecognizer.panningDirection;
            
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
            const CGFloat rawPercent = point / dragAmount;
            const CGFloat percent = fmin(fmax(rawPercent, 0), 1);
            
            self.point = newPoint;
            _shouldComplete = ABS(rawPercent) > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.interactionEnabled) {
                return;
            }
            
            self.transition.interactionEnabled = NO;
            
            if (self.isCompletionSpeed || (_gestureRecognizer.state == UIGestureRecognizerStateEnded && _shouldComplete && self.isCompletionDirection)) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            break;
        }
        default:
            break;
    }
}

@end

@implementation UIPanGestureRecognizer (pisces_UIViewControllerTransitions)
- (PanningDirection)panningDirection {
    CGPoint velocity = [self velocityInView:self.view];
    BOOL vertical = fabs(velocity.y) > fabs(velocity.x * 3);
    
    if (vertical) {
        if (velocity.y < 0) return PanningDirectionUp;
        if (velocity.y > 0) return PanningDirectionDown;
    }
    
    if (velocity.x > 0) return PanningDirectionRight;
    if (velocity.x < 0) return PanningDirectionLeft;
    
    return PanningDirectionNone;
}

@end
