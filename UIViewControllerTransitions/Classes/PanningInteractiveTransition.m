//
//  PanningInteractiveTransition.m
//  Pods
//
//  Created by pisces on 11/04/2017.
//
//

#import "PanningInteractiveTransition.h"

@implementation PanningInteractiveTransition
{
@private
    BOOL shouldComplete;
    UIViewController *_viewController;
    UIViewController *_presentViewController;
}

#pragma mark - Overridden: UIPercentDrivenInteractiveTransition

- (void)dealloc {
    [_panGestureRecognizer removeTarget:self action:@selector(panned)];
}

- (id)init {
    self = [super init];
    
    if (self) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned)];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)attach:(UIViewController *)viewController presentViewController:(UIViewController *)presentViewController {
    [self detach];
    
    _viewController = viewController;
    _presentViewController = presentViewController;
    
    [_viewController.view addGestureRecognizer:_panGestureRecognizer];
}

- (void)detach {
    [_viewController.view removeGestureRecognizer:_panGestureRecognizer];
    _viewController = nil;
    _presentViewController = nil;
}

#pragma mark - Private selector

- (void)panned {
    switch (_panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (_presentViewController) {
                [_viewController presentViewController:_presentViewController animated:YES completion:nil];
            } else {
                [_viewController dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [_panGestureRecognizer translationInView:_viewController.view.superview];
            const CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
            const CGFloat dragAmount = -screenHeight;
            const CGFloat threshold = 0.3;
            const CGFloat percent = fmin(fmax(translation.y / dragAmount, 0), 1);
            shouldComplete = percent > threshold;
            
            [self updateInteractiveTransition:percent];
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            if (_panGestureRecognizer.state == UIGestureRecognizerStateCancelled || !shouldComplete) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

@end
