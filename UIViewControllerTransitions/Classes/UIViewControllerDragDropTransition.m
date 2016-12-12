//
//  UIViewControllerDragDropTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "UIViewControllerDragDropTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerDragDropTransition

@synthesize dismissionDataSource = _dismissionDataSource;

// ================================================================================================
//  Overridden: AbstractUIViewControllerTransition
// ================================================================================================

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (void)initProperties {
    [super initProperties];
    
    _imageViewContentMode = UIViewContentModeScaleAspectFill;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedDragDropTransition *transition = [AnimatedDragDropTransition new];
    transition.imageViewContentMode = _imageViewContentMode;
    transition.transitionSource = _dismissionSource;
    transition.dismissiontImageView = dismissionImageView;
    transition.duration = self.durationForDismission;
    
    if ([_dismissionDataSource respondsToSelector:@selector(sourceImageForDismission)]) {
        transition.sourceImage = [_dismissionDataSource sourceImageForDismission];
    }
    
    dismissionImageView = nil;
    
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedDragDropTransition *transition = [AnimatedDragDropTransition new];
    transition.presenting = YES;
    transition.duration = self.durationForPresenting;
    transition.imageViewContentMode = _imageViewContentMode;
    transition.transitionSource =_presentingSource;
    transition.sourceImage = _sourceImage;
    return transition;
}

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
    const BOOL hasSouceImageForDismission = [_dismissionDataSource respondsToSelector:@selector(sourceImageForDismission)] && [_dismissionDataSource sourceImageForDismission];
    const UIImage *dismissionImage = hasSouceImageForDismission ? [_dismissionDataSource sourceImageForDismission] : _sourceImage;
    
    if (dismissionImage) {
        dismissionImageView = [[UIMaskedImageView alloc] initWithImage:dismissionImage];
        dismissionImageView.backgroundColor = [UIColor clearColor];
        dismissionImageView.clipsToBounds = YES;
        dismissionImageView.contentMode = _imageViewContentMode;
        dismissionImageView.frame = hasSouceImageForDismission && [_dismissionDataSource respondsToSelector:@selector(sourceImageRectForDismission)] ? [_dismissionDataSource sourceImageRectForDismission] : [_presentingSource to]();
        
        originDismissionImageViewPoint = dismissionImageView.frame.origin;
        
        [self.viewController.view.window addSubview:dismissionImageView];
    }
    
    self.viewController.view.window.backgroundColor = [UIColor blackColor];
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
}

- (void)animateTransitionCancelled:(UIPanGestureRecognizer *)gestureRecognizer {
    self.viewController.view.alpha = 1;
    self.viewController.presentingViewController.view.alpha = 0;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.viewController;
        navigationController.navigationBar.alpha = 1;
    }
    
    [UIView animateWithDuration:0.25 delay:0 options:7<<16 animations:^{
        dismissionImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        dismissionImageView.frame = CGRectMakeXY(dismissionImageView.frame, originDismissionImageViewPoint.x, originDismissionImageViewPoint.y);
    } completion:nil];
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
    const CGPoint p = [gestureRecognizer locationInView:self.viewController.view.window];
    const CGFloat y = self.originViewPoint.y + (p.y - self.originPoint.y);
    const CGFloat alpha = MIN(0.5, 0.5 * ABS(y) / self.bounceHeight);
    const CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * ABS(y) / self.bounceHeight));
    const CGFloat imageScale = MIN(1, (MAX(0.5, 1 - ABS(y)/CGRectGetHeight(self.viewController.view.frame))));
    
    self.viewController.presentingViewController.view.hidden = NO;
    self.viewController.presentingViewController.view.alpha = alpha;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    self.viewController.view.alpha = 1 - alpha;
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.viewController;
        navigationController.navigationBar.alpha = 1 - ABS(y)/self.bounceHeight;
    }
    
    dismissionImageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(imageScale, imageScale), (p.x - self.originPoint.x), (p.y - self.originPoint.y));
}

- (void)animateTransitionCancelCompleted {
    self.viewController.presentingViewController.view.hidden = YES;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    originDismissionImageViewPoint = CGPointZero;
    
    [dismissionImageView removeFromSuperview];
}

@end
