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
#import "UIViewControllerAnimatedTransition.h"

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

#pragma mark - Private methods

- (BOOL)isCompletionSpeed {
    BOOL isVertical = self.direction == InteractiveTransitionDirectionVertical;
    CGPoint velocity = [self.panGestureRecognizer velocityInView:self.currentViewController.view.superview];
    CGFloat value = isVertical ? velocity.y : velocity.x;
    CGFloat speed = -1 * value / (isVertical ? (self.beginPoint.y - self.point.y) : (self.beginPoint.x - self.point.x));
    return speed > 10;
}

#pragma mark - Private selector

- (void)panned {
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if (self.transition.transitioning.isAnimating ||
                self.transition.interactionEnabled ||
                ([self.delegate respondsToSelector:@selector(interactor:shouldInteractionWithGestureRecognizer:)] &&
                ![self.delegate interactor:self shouldInteractionWithGestureRecognizer:_gestureRecognizer])) {
                return;
            }
            
            self.transition.interactionEnabled = YES;
            self.beginPoint = newPoint;
            self.beginViewPoint = self.currentViewController.view.frame.origin;
            panningDirection = self.panGestureRecognizer.panningDirection;
            
            if (self.navigationController) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                if (self.presentViewController == nil) {
                    [self.viewController dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transition.interactionEnabled || ![self.transition.currentInteractor isEqual:self]) {
                return;
            }
            
            const CGPoint translation = [self.panGestureRecognizer translationInView:self.currentViewController.view.superview];
            const CGFloat targetSize = self.direction == InteractiveTransitionDirectionVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat point = self.direction == InteractiveTransitionDirectionVertical ? translation.y : translation.x;
            const CGFloat dragAmount = targetSize * (self.presentViewController ? -1 : 1);
            const CGFloat threshold = self.transition.transitioning.completionBounds / targetSize;
            const CGFloat rawPercent = point / dragAmount;
            const CGFloat percent = fmin(fmax(-1, rawPercent), 1);
            
            self.point = newPoint;
            _shouldComplete = ABS(rawPercent) > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.interactionEnabled || ![self.transition.currentInteractor isEqual:self]) {
                return;
            }
            
            if ([self.transition.transitioning shouldComplete:self] &&
                (self.isCompletionSpeed || (_gestureRecognizer.state == UIGestureRecognizerStateEnded && _shouldComplete))) {
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
    CGFloat ratio = UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width;
    BOOL vertical = fabs(velocity.y) > fabs(velocity.x * ratio);
    
    if (vertical) {
        if (velocity.y < 0) return PanningDirectionUp;
        if (velocity.y > 0) return PanningDirectionDown;
    }
    
    if (velocity.x > 0) return PanningDirectionRight;
    if (velocity.x < 0) return PanningDirectionLeft;
    
    return PanningDirectionNone;
}

@end
