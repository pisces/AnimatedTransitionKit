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

+ (AnimatedDragDropTransitioningSource *)image:(AnimatedDragDropTransitioningImageBlock)image
                                          from:(AnimatedDragDropTransitioningSourceBlock)from
                                            to:(AnimatedDragDropTransitioningSourceBlock)to
                                      rotation:(AnimatedDragDropTransitioningValueBlock)rotation
                                    completion:(AnimatedDragDropTransitioningCompletionBlock)completion {
    AnimatedDragDropTransitioningSource *source = [AnimatedDragDropTransitioningSource new];
    source.image = image;
    source.from = from;
    source.to = to;
    source.rotation = rotation;
    source.completion = completion;
    return source;
}

@end

@implementation AnimatedDragDropTransitioning
{
@private
    UIImageView *sourceImageView;
}

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForDismission:transitionContext];
    
    UIColor *backgroundColor = toViewController.view.window.backgroundColor;
    
    toViewController.view.hidden = NO;
    toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (!sourceImageView) {
        sourceImageView = [self createImageView];
        [transitionContext.containerView addSubview:sourceImageView];
    }
    
    [toViewController viewWillAppear:YES];
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            [self dismiss];
        } completion:^(BOOL finished) {
            toViewController.view.window.backgroundColor = backgroundColor;
            
            [self completion];
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];
    
    UIColor *backgroundColor = fromViewController.view.window.backgroundColor;
    sourceImageView = [self createImageView];
    fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [transitionContext.containerView addSubview:toViewController.view];
    [transitionContext.containerView addSubview:sourceImageView];
    [fromViewController viewWillDisappear:YES];
    
    toViewController.view.alpha = 0;
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            toViewController.view.alpha = 1;
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
            
            sourceImageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
            sourceImageView.frame = _source.to();
        } completion:^(BOOL finished) {
            fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (!transitionContext.transitionWasCancelled) {
                fromViewController.view.hidden = YES;
            }
            
            [self completion];
        }];
    }
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    if (self.presenting) {
        return;
    }
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:self.animationOptions |  UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.alpha = 1;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        sourceImageView.transform = CGAffineTransformMakeScale(1, 1);
        sourceImageView.frame = _source.from();
    } completion:^(BOOL finished) {
        [self cancel];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    if (self.presenting) {
        return;
    }
    
    const CGFloat bounceHeight = self.aboveViewController.transition.bounceHeight;
    const CGFloat y = interactor.beginViewPoint.y + (interactor.point.y - interactor.beginPoint.y);
    const CGFloat progress = ABS(y) / bounceHeight;
    const CGFloat alpha = 1 - progress;
    const CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * progress));
    const CGFloat imageScale = MIN(1, (MAX(0.5, 1 - ABS(y) / self.aboveViewController.view.bounds.size.height)));
    
    sourceImageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(imageScale, imageScale), (interactor.point.x - interactor.beginPoint.x), (interactor.point.y - interactor.beginPoint.y));
    self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    self.aboveViewController.view.alpha = alpha;
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^)(void))completion {
    [super interactionCompleted:interactor completion:completion];
    
    if (self.presenting) {
        return;
    }
    
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self dismiss];
    } completion:^(BOOL finished) {
        [self completion];
    }];
}

#pragma mark - Protected methods

- (void)clear {
    [_source clear];
    _source = nil;
    sourceImageView = nil;
}

- (UIMaskedImageView *)createImageView {
    UIMaskedImageView *imageView = [[UIMaskedImageView alloc] initWithFrame:_source.from()];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    imageView.contentMode = _imageViewContentMode;
    imageView.image = _source.image();
    imageView.layer.anchorPoint = CGPointMake(0.5, 0.5);
    return imageView;
}

#pragma mark - Private methods

- (CGFloat)angle {
    if (![_source respondsToSelector:@selector(rotation)] || !_source.rotation) {
        return 0;
    }
    CGFloat rotation = _source.rotation();
    return rotation != 0 ? rotation * M_PI / 180 : 0;
}

- (void)cancel {
    if (self.presenting) {
        [self.aboveViewController.view removeFromSuperview];
    }
    
    [context completeTransition:!context.transitionWasCancelled];
    [sourceImageView removeFromSuperview];
    sourceImageView = nil;
}

- (void)completion {
    [self.belowViewController beginAppearanceTransition:!self.presenting animated:YES];
    
    if (_source.completion) {
        _source.completion();
    }
    
    [context completeTransition:!context.transitionWasCancelled];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sourceImageView removeFromSuperview];
        [self clear];
    });
}

- (void)dismiss {
    self.aboveViewController.view.alpha = 0;
    self.belowViewController.view.transform = CGAffineTransformMakeScale(1, 1);
    self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    
    sourceImageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
    sourceImageView.frame = _source.to();
}

@end
