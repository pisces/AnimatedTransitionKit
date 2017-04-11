//
//  AnimatedDragDropTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import "AnimatedDragDropTransition.h"
#import "AbstractUIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedDragDropTransitionSource

#pragma mark - Public methods

- (void)clear {
    _from = nil;
    _to = nil;
    _completion = nil;
}

- (AnimatedDragDropTransitionSource *)from:(AnimatedDragDropTransitionSourceBlock)from
                                        to:(AnimatedDragDropTransitionSourceBlock)to
                                  rotation:(AnimatedDragDropTransitionValueBlock)rotation
                                completion:(AnimatedDragDropTransitionCompletionBlock)completion {
    _from = from;
    _to = to;
    _rotation = rotation;
    _completion = completion;
    return self;
}

@end

@implementation AnimatedDragDropTransition

#pragma mark - Overridden: AnimatedTransition

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = toViewController.view.userInteractionEnabled;
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    UIImageView *imageView = _dismissiontImageView ? _dismissiontImageView : [self createImageView];
    
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    if (!_dismissiontImageView) {
        [fromViewController.view.window addSubview:imageView];
    }
    
    toViewController.view.hidden = NO;
    CGRect to = _transitionSource.to();
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (toViewController.view.alpha <= 0) {
        toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:7 animations:^{
        imageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
        imageView.frame = to;
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = userInteractionEnabled;
        toViewController.view.window.backgroundColor = backgroundColor;
        
        [fromViewController viewDidDisappear:YES];
        [fromViewController.view removeFromSuperview];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        _transitionSource.completion();
        
        [imageView removeFromSuperview];
        [self clear];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    BOOL userInteractionEnabled = fromViewController.view.userInteractionEnabled;
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    
    UIImageView *imageView = [self createImageView];
    
    fromViewController.view.userInteractionEnabled = NO;
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [fromViewController.view.window addSubview:imageView];
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.alpha = 0;
    toViewController.view.frame = fromViewController.view.bounds;
    toViewController.transition.panGestureRecognizer.enabled = NO;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:7 animations:^{
        imageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
        imageView.frame = _transitionSource.to();
        toViewController.view.alpha = 1;
        fromViewController.view.alpha = 0;
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        fromViewController.view.userInteractionEnabled = userInteractionEnabled;
        fromViewController.view.window.backgroundColor = backgroundColor;
        
        if (![transitionContext transitionWasCancelled]) {
            fromViewController.view.hidden = YES;
        }
        
        _transitionSource.completion();
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imageView removeFromSuperview];
            [self clear];
            toViewController.transition.panGestureRecognizer.enabled = YES;
        });
    }];
}

#pragma mark - Protected methods

- (void)clear {
    [_transitionSource clear];
    
    _transitionSource = nil;
}

- (UIMaskedImageView *)createImageView {
    UIMaskedImageView *imageView = [[UIMaskedImageView alloc] initWithFrame:_transitionSource.from()];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    imageView.contentMode = _imageViewContentMode;
    imageView.image = _sourceImage;
    imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    return imageView;
}

#pragma mark - Private methods

- (CGFloat)angle {
    if (![_transitionSource respondsToSelector:@selector(rotation)] || !_transitionSource.rotation) {
        return 0;
    }
    CGFloat rotation = _transitionSource.rotation();
    return rotation != 0 ? rotation * M_PI / 180 : 0;
}

@end
