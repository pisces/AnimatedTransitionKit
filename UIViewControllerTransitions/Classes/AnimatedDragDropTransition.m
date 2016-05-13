//
//  AnimatedDragDropTransition.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import "AnimatedDragDropTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedDragDropTransitionSource

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public methods

- (void)clear {
    _from = nil;
    _to = nil;
    _completion = nil;
}

- (AnimatedDragDropTransitionSource *)from:(AnimatedDragDropTransitionSourceBlock)from
                                        to:(AnimatedDragDropTransitionSourceBlock)to
                                completion:(AnimatedDragDropTransitionCompletionBlock)completion {
    _from = from;
    _to = to;
    _completion = completion;
    return self;
}

@end

@implementation AnimatedDragDropTransition

// ================================================================================================
//  Overridden: AnimatedTransition
// ================================================================================================

#pragma mark - Overridden: AnimatedTransition

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIImageView *imageView = _dismissiontImageView ? _dismissiontImageView : [self createImageView];
    
    [toViewController viewWillAppear:YES];
    
    if (!_dismissiontImageView)
        [fromViewController.view.window addSubview:imageView];
    
    toViewController.view.hidden = NO;
    CGRect to = _transitionSource.to();
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (toViewController.view.alpha <= 0)
        toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        imageView.frame = to;
        fromViewController.view.alpha = 0;
        toViewController.view.alpha = 1;
        toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    } completion:^(BOOL finished) {
        toViewController.view.userInteractionEnabled = YES;
        toViewController.view.window.backgroundColor = [UIColor whiteColor];
        
        [imageView removeFromSuperview];
        [fromViewController.view removeFromSuperview];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:YES];
        
        _transitionSource.completion();
        
        [self clear];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIImageView *imageView = [self createImageView];
    
    fromViewController.view.userInteractionEnabled = NO;
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [fromViewController.view.window addSubview:imageView];
    [transitionContext.containerView addSubview:toViewController.view];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.alpha = 0;
    toViewController.view.frame = fromViewController.view.bounds;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:7<<16 animations:^{
        imageView.frame = _transitionSource.to();
        toViewController.view.alpha = 1;
        fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    } completion:^(BOOL finished) {
        [fromViewController viewDidDisappear:YES];
        [toViewController viewDidAppear:YES];
        [transitionContext completeTransition:YES];
        
        fromViewController.view.hidden = YES;
        fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imageView removeFromSuperview];
            
            _transitionSource.completion();
            
            [self clear];
        });
    }];
}

// ================================================================================================
//  Protected
// ================================================================================================

#pragma mark - Protected methods

- (void)clear {
    [_transitionSource clear];
    
    _transitionSource = nil;
}

- (UIMaskedImageView *)createImageView {
    UIMaskedImageView *imageView = [[UIMaskedImageView alloc] initWithFrame:_transitionSource.from()];
    imageView.clipsToBounds = YES;
    imageView.backgroundColor = [UIColor clearColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = _sourceImage;
    return imageView;
}
                                     
@end