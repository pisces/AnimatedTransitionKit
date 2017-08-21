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
#import "AbstractTransition.h"

BOOL PanningDirectionIsVertical(PanningDirection direction) {
    return direction == PanningDirectionUp || direction == PanningDirectionDown;
}

@interface PanningInteractiveTransition ()
@property (nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end

@implementation PanningInteractiveTransition
@synthesize gestureRecognizer = _gestureRecognizer;
@synthesize shouldComplete = _shouldComplete;
@synthesize beginPoint = _beginPoint;
@synthesize beginViewPoint = _beginViewPoint;
@synthesize point = _point;

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
    CGPoint velocity = [self.panGestureRecognizer velocityInView:self.currentViewController.view.superview];
    CGFloat value = self.isVertical ? velocity.y : velocity.x;
    CGFloat speed = -1 * value / (self.isVertical ? (self.beginPoint.y - self.point.y) : (self.beginPoint.x - self.point.x));
    return speed > 10;
}

#pragma mark - Private selector

- (void)panned {
    const CGPoint newPoint = [self.panGestureRecognizer locationInView:self.currentViewController.view.superview];
    
    switch (self.panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            _panningDirection = self.panGestureRecognizer.panningDirection;
            
            if (self.transition.transitioning.isAnimating ||
                self.transition.isInteractionEnabled ||
                ![self.transition isValidWithInteractor:self] ||
                ([self.delegate respondsToSelector:@selector(interactor:shouldInteractionWithGestureRecognizer:)] &&
                ![self.delegate interactor:self shouldInteractionWithGestureRecognizer:_gestureRecognizer])) {
                return;
            }
            
            self.transition.interactionEnabled = YES;
            _beginPoint = newPoint;
            _beginViewPoint = self.currentViewController.view.frame.origin;
            
            if (![self beginInteractiveTransition]) {
                self.transition.interactionEnabled = NO;
            }
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.transition.isInteractionEnabled || ![self.transition.currentInteractor isEqual:self]) {
                return;
            }
            
            const BOOL isAppearing = [self.transition isAppearingWithInteractor:self];
            const CGPoint translation = [self.panGestureRecognizer translationInView:self.currentViewController.view.superview];
            const CGFloat targetSize = self.direction == InteractiveTransitionDirectionVertical ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width;
            const CGFloat point = self.direction == InteractiveTransitionDirectionVertical ? translation.y : translation.x;
            const CGFloat dragAmount = targetSize * (isAppearing ? -1 : 1);
            const CGFloat threshold = self.transition.transitioning.completionBounds / targetSize;
            const CGFloat rawPercent = point / dragAmount;
            const CGFloat percent = fmin(fmax(-1, rawPercent), 1);
            
            _point = newPoint;
            _shouldComplete = ABS(rawPercent) > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (!self.transition.isInteractionEnabled || ![self.transition.currentInteractor isEqual:self]) {
                return;
            }
            
            if ([self.transition.transitioning shouldComplete:self] &&
                (self.isCompletionSpeed || (_gestureRecognizer.state == UIGestureRecognizerStateEnded && self.shouldComplete))) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
            
            self.transition.interactionEnabled = NO;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Protected methods

- (BOOL)beginInteractiveTransition {
    if ([self.transition isAppearingWithInteractor:self]) {
        if (!self.presentViewController) {
            return NO;
        }
        [self.viewController presentViewController:self.presentViewController animated:YES completion:nil];
    } else {
        if (!self.viewController) {
            return NO;
        }
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    }
    return YES;
}

@end

@implementation UIPanGestureRecognizer (UIViewControllerTransitions)
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
