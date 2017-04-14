//
//  AnimatedDragDropTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedDragDropTransitioning.h"
#import "AbstractUIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation AnimatedDragDropTransitioningSource

#pragma mark - Public methods

- (void)clear {
    _from = nil;
    _to = nil;
    _completion = nil;
}

- (AnimatedDragDropTransitioningSource *)from:(AnimatedDragDropTransitioningSourceBlock)from
                                        to:(AnimatedDragDropTransitioningSourceBlock)to
                                  rotation:(AnimatedDragDropTransitioningValueBlock)rotation
                                completion:(AnimatedDragDropTransitioningCompletionBlock)completion {
    _from = from;
    _to = to;
    _rotation = rotation;
    _completion = completion;
    return self;
}

@end

@implementation AnimatedDragDropTransitioning

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    UIImageView *imageView = _dismissionImageView ? _dismissionImageView : [self createImageView];
    
    if (!_dismissionImageView) {
        [toViewController.view.window addSubview:imageView];
        _dismissionImageView = imageView;
    }
    
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:7 animations:^{
        if (!transitionContext.isInteractive) {
            [self dismissWithImageView:imageView fromViewController:fromViewController toViewController:toViewController];
        }
    } completion:^(BOOL finished) {
        if (!transitionContext.isInteractive) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [self endWithImageView:imageView fromViewController:fromViewController toViewController:toViewController];
        }
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    UIImageView *imageView = [self createImageView];
    
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [fromViewController.view.window addSubview:imageView];
    [fromViewController viewWillDisappear:YES];
    [toViewController viewWillAppear:YES];
    [transitionContext.containerView addSubview:toViewController.view];
    
    toViewController.view.alpha = 0;
    [self setNavigationBarAlpha:toViewController];
    
    [UIView animateWithDuration:[self currentDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:7 animations:^{
        if (!transitionContext.isInteractive) {
            toViewController.view.alpha = 1;
            fromViewController.view.alpha = 0.5;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
            
            imageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
            imageView.frame = _transitionSource.to();
            
            [self setNavigationBarAlpha:toViewController];
        }
    } completion:^(BOOL finished) {
        if (!transitionContext.isInteractive) {
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (!transitionContext.transitionWasCancelled) {
                fromViewController.view.hidden = YES;
            }
            
            [fromViewController viewDidDisappear:YES];
            [toViewController viewDidAppear:YES];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
            _transitionSource.completion();
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [imageView removeFromSuperview];
                [self clear];
            });
        }
    }];
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    if (self.presenting) {
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        self.aboveViewController.view.alpha = 1;
        self.belowViewController.view.alpha = 0;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        _dismissionImageView.transform = CGAffineTransformMakeScale(1, 1);
        _dismissionImageView.frame = _transitionSource.from();
        
        [self setNavigationBarAlpha:self.aboveViewController];
    } completion:^(BOOL finished) {
        [self.aboveViewController viewDidAppear:YES];
        [self.belowViewController viewDidDisappear:YES];
        [_dismissionImageView removeFromSuperview];
        _dismissionImageView = nil;
        
        completion();
    }];
    
    [context completeTransition:!context.transitionWasCancelled];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    if (self.presenting) {
        return;
    }
    
    const CGFloat bounceHeight = self.aboveViewController.transition.bounceHeight;
    const CGFloat y = interactor.beginViewPoint.y + (interactor.point.y - interactor.beginPoint.y);
    const CGFloat progress = ABS(y) / bounceHeight;
    const CGFloat alpha = MIN(0.5, 0.5 * progress);
    const CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * progress));
    const CGFloat imageScale = MIN(1, (MAX(0.5, 1 - ABS(y) / self.screenSize.height)));
    
    _dismissionImageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(imageScale, imageScale), (interactor.point.x - interactor.beginPoint.x), (interactor.point.y - interactor.beginPoint.y));
    
    self.belowViewController.view.alpha = alpha;
    self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    self.aboveViewController.view.alpha = 1 - (1 * progress);
    
    [self setNavigationBarAlpha:self.aboveViewController];
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^)(void))completion {
    [super interactionCompleted:interactor completion:completion];
    
    if (self.presenting) {
        return;
    }
    
    [UIView animateWithDuration:0.2 delay:0 options:7<<16 animations:^{
        [self dismissWithImageView:_dismissionImageView fromViewController:self.aboveViewController toViewController:self.belowViewController];
    } completion:^(BOOL finished) {
        [self endWithImageView:_dismissionImageView fromViewController:self.aboveViewController toViewController:self.belowViewController];
        _dismissionImageView = nil;
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

- (void)dismissWithImageView:(UIImageView *)imageView fromViewController:(UIViewController *)_fromViewController toViewController:(UIViewController *)_toViewController {
    _fromViewController.view.alpha = 0;
    _toViewController.view.alpha = 1;
    _toViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    _toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    imageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
    imageView.frame = _transitionSource.to();
    
    [self setNavigationBarAlpha:_fromViewController];
}

- (void)endWithImageView:(UIImageView *)imageView fromViewController:(UIViewController *)_fromViewController toViewController:(UIViewController *)_toViewController {
    [_fromViewController viewDidDisappear:YES];
    [_toViewController viewDidAppear:YES];
    [context completeTransition:!context.transitionWasCancelled];
    _transitionSource.completion();
    
    [imageView removeFromSuperview];
    [self clear];
}

- (void)setNavigationBarAlpha:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        ((UINavigationController *) viewController).navigationBar.alpha = viewController.view.alpha;
    }
}

@end
