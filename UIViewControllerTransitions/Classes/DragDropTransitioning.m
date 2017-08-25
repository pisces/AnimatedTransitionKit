//
//  DragDropTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedDragDropTransitioning to DragDropTransitioning
//

#import "DragDropTransitioning.h"
#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation DragDropTransitioningSource

#pragma mark - Public methods

- (void)clear {
    _from = nil;
    _to = nil;
    _completion = nil;
}

+ (DragDropTransitioningSource *)image:(DragDropTransitioningImageBlock)image
                                  from:(DragDropTransitioningSourceBlock)from
                                    to:(DragDropTransitioningSourceBlock)to
                              rotation:(DragDropTransitioningValueBlock)rotation
                            completion:(DragDropTransitioningCompletionBlock)completion {
    DragDropTransitioningSource *source = [DragDropTransitioningSource new];
    source.image = image;
    source.from = from;
    source.to = to;
    source.rotation = rotation;
    source.completion = completion;
    return source;
}

@end

@implementation DragDropTransitioning
{
@private
    UIImageView *sourceImageView;
}

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIColor *backgroundColor = self.toViewController.view.window.backgroundColor;
    
    self.toViewController.view.hidden = NO;
    self.toViewController.view.window.backgroundColor = [UIColor blackColor];
    
    if (!sourceImageView) {
        sourceImageView = [self createImageView];
        [transitionContext.containerView addSubview:sourceImageView];
    }
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            [self dismiss];
        } completion:^(BOOL finished) {
            self.toViewController.view.window.backgroundColor = backgroundColor;
            
            [self.fromViewController endAppearanceTransition];
            [self.toViewController endAppearanceTransition];
            [self completion:nil];
        }];
    }
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIColor *backgroundColor = self.fromViewController.view.window.backgroundColor;
    sourceImageView = [self createImageView];
    self.fromViewController.view.window.backgroundColor = [UIColor blackColor];
    
    [transitionContext.containerView addSubview:self.toViewController.view];
    [transitionContext.containerView addSubview:sourceImageView];
    
    self.toViewController.view.alpha = 0;
    
    if (!transitionContext.isInteractive) {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
            self.toViewController.view.alpha = 1;
            self.fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            self.fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
            
            sourceImageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
            sourceImageView.frame = _source.to();
        } completion:^(BOOL finished) {
            self.fromViewController.view.alpha = 1;
            self.fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            self.fromViewController.view.window.backgroundColor = backgroundColor;
            
            if (!transitionContext.transitionWasCancelled) {
                self.fromViewController.view.hidden = YES;
            }
            
            [self.fromViewController endAppearanceTransition];
            [self.toViewController endAppearanceTransition];
            [self completion:nil];
        }];
    }
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    if (self.presenting) {
        return;
    }
    
    [self.belowViewController beginAppearanceTransition:NO animated:self.context.isAnimated];
    [self.aboveViewController beginAppearanceTransition:YES animated:self.context.isAnimated];
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:self.animationOptions |  UIViewAnimationOptionAllowUserInteraction animations:^{
        self.aboveViewController.view.alpha = 1;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        sourceImageView.transform = CGAffineTransformMakeScale(1, 1);
        sourceImageView.frame = _source.from();
    } completion:^(BOOL finished) {
        [self cancel:completion];
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    if (self.presenting) {
        return;
    }
    
    const CGFloat y = interactor.beginViewPoint.y + (interactor.point.y - interactor.beginPoint.y);
    const CGFloat progress = ABS(y) / self.completionBounds;
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
    
    [self.belowViewController beginAppearanceTransition:YES animated:self.context.isAnimated];
    [self.aboveViewController beginAppearanceTransition:NO animated:self.context.isAnimated];
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1.0 options:7 | UIViewAnimationOptionAllowUserInteraction animations:^{
        [self dismiss];
    } completion:^(BOOL finished) {
        [self.fromViewController endAppearanceTransition];
        [self.toViewController endAppearanceTransition];
        [self completion:completion];
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

- (void)cancel:(void(^)(void))block {
    if (self.presenting) {
        [self.aboveViewController.view removeFromSuperview];
    } else {
        self.belowViewController.view.hidden = YES;
    }
    
    [self.fromViewController endAppearanceTransition];
    [self.toViewController endAppearanceTransition];
    
    dispatch_after_sec(0.05, ^{
        [self.context completeTransition:!self.context.transitionWasCancelled];
        [sourceImageView removeFromSuperview];
        sourceImageView = nil;
        
        if (block) {
            block();
        }
    });
}

- (void)completion:(void(^)(void))block {
    if (_source.completion) {
        _source.completion();
    }
    
    dispatch_after_sec(0.05, ^{
        [self.context completeTransition:!self.context.transitionWasCancelled];
        
        if (block) {
            block();
        }
    });
    dispatch_after_sec(0.2, ^{
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
