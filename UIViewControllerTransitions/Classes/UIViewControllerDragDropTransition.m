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

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedDragDropTransition *transition = [AnimatedDragDropTransition new];
    transition.transitionSource = _dismissionSource;
    transition.dismissiontImageView = dismissionImageView;
    
    if ([_dismissionDataSource respondsToSelector:@selector(sourceImageForDismission)]) {
        transition.sourceImage = [_dismissionDataSource sourceImageForDismission];
    }
    
    dismissionImageView = nil;
    
    return transition;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedDragDropTransition *transition = [AnimatedDragDropTransition new];
    transition.presenting = YES;
    transition.transitionSource =_presentingSource;
    transition.sourceImage = _sourceImage;
    return transition;
}

- (void)animateTransitionBegan:(UIPanGestureRecognizer *)gestureRecognizer {
    UIImage *dismissionImage = [_dismissionDataSource respondsToSelector:@selector(sourceImageForDismission)] ? [_dismissionDataSource sourceImageForDismission] : nil;
    
    if (dismissionImage) {
        dismissionImageView = [[UIMaskedImageView alloc] initWithImage:dismissionImage];
        dismissionImageView.contentMode = UIViewContentModeScaleAspectFill;
        dismissionImageView.clipsToBounds = YES;
        
        if ([_dismissionDataSource respondsToSelector:@selector(sourceImageRectForDismission)])
            dismissionImageView.frame = [_dismissionDataSource sourceImageRectForDismission];
        
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
    
    dismissionImageView.frame = CGRectMakeXY(dismissionImageView.frame, originDismissionImageViewPoint.x, originDismissionImageViewPoint.y);
}

- (void)animateTransitionChanged:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.viewController.view.window];
    CGFloat y = originViewPoint.y + (p.y - originPoint.y);
    CGFloat alpha = MIN(0.5, 0.5 * ABS(y) / self.bounceHeight);
    CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * ABS(y) / self.bounceHeight));
    
    self.viewController.presentingViewController.view.hidden = NO;
    self.viewController.presentingViewController.view.alpha = alpha;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    self.viewController.view.alpha = 1 - alpha;
    
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *) self.viewController;
        navigationController.navigationBar.alpha = 1 - ABS(y)/self.bounceHeight;
    }
    
    dismissionImageView.frame = CGRectMakeXY(dismissionImageView.frame, originDismissionImageViewPoint.x + (p.x - originPoint.x), originDismissionImageViewPoint.y + (p.y - originPoint.y));
}

- (void)animateTransitionCancelCompleted {
    self.viewController.presentingViewController.view.hidden = YES;
    self.viewController.presentingViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    originDismissionImageViewPoint = CGPointZero;
    
    [dismissionImageView removeFromSuperview];
}

@end
