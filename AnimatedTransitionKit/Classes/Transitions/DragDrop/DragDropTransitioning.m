//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  DragDropTransitioning.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedDragDropTransitioning to DragDropTransitioning
//

#import "DragDropTransitioning.h"
#import "AnimatedTransition.h"
#import "AnimatedTransitionKitMacro.h"

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
    CGPoint beginViewPoint;
    UIImageView *sourceImageView;
}

#pragma mark - Overridden: AnimatedTransitioning

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isAllowsDeactivating) {
        self.toViewController.view.hidden = NO;
    }
    
    if (!sourceImageView) {
        sourceImageView = [self createImageView];
        [transitionContext.containerView addSubview:sourceImageView];
    }
    
    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        [self animateDismission];
    } completion:^{
        [self completeSource];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [self.fromViewController.view removeFromSuperview];

        if (self.isAllowsAppearanceTransition) {
            [self.belowViewController endAppearanceTransition];
        }
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];

    sourceImageView = [self createImageView];

    self.toViewController.view.alpha = 0;
    [transitionContext.containerView addSubview:self.toViewController.view];
    [transitionContext.containerView addSubview:sourceImageView];

    if (transitionContext.isInteractive) {
        return;
    }
    
    [self animate:^{
        self.toViewController.view.alpha = 1;

        if (self.isAllowsDeactivating) {
            self.fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            self.fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        }

        self->sourceImageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
        self->sourceImageView.frame = self->_source.to();
    } completion:^{
        if (self.isAllowsDeactivating) {
            self.fromViewController.view.alpha = 1;
            self.fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);

            if (!transitionContext.transitionWasCancelled) {
                self.fromViewController.view.hidden = YES;
            }
        }

        if (self.isAllowsAppearanceTransition) {
            [self.fromViewController endAppearanceTransition];
        }
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [self completeSource];
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];
    
    beginViewPoint = interactor.currentViewController.view.frame.origin;
    
    if (self.presenting) {
        return;
    }

    if (self.isAllowsAppearanceTransition) {
        [self.belowViewController beginAppearanceTransition:!self.presenting animated:transitionContext.isAnimated];
    }
    
    self.aboveViewController.view.hidden = NO;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    [super interactionCancelled:interactor completion:completion];
    
    beginViewPoint = CGPointZero;
    
    if (self.presenting) {
        return;
    }
    
    [self animateWithDuration:0.25 animations:^{
        self.aboveViewController.view.alpha = 1;

        if (self.isAllowsDeactivating) {
            self.belowViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
            self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        }
        
        self->sourceImageView.transform = CGAffineTransformMakeScale(1, 1);
        self->sourceImageView.frame = self->_source.from();
    } completion:^{
        if (self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        } else {
            if (self.isAllowsDeactivating) {
                self.belowViewController.view.hidden = YES;
            }
            if (self.isAllowsAppearanceTransition) {
                [self.belowViewController endAppearanceTransition];
            }
            [self.context completeTransition:NO];
        }

        completion();
        [self clearSourceImageView];
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];
    
    if (self.presenting) {
        return;
    }
    
    const CGFloat y = beginViewPoint.y + interactor.translation.y;
    const CGFloat imageScale = MIN(1, (MAX(0.5, 1 - ABS(y) / self.aboveViewController.view.bounds.size.height)));
    
    sourceImageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(imageScale, imageScale), interactor.translation.x, interactor.translation.y);

    if (self.isAllowsDeactivating) {
        const CGFloat alpha = 1 - self.percentOfCompletion;
        const CGFloat scale = MIN(1, 0.94 + ((1 - 0.94) * self.percentOfCompletion));
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        self.aboveViewController.view.alpha = alpha;
    }
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^)(void))completion {
    [super interactionCompleted:interactor completion:completion];
    
    beginViewPoint = CGPointZero;
    
    if (self.presenting) {
        return;
    }
    
    [self animate:^{
        [self animateDismission];
    } completion:^{
        completion();
        [self completeSource];
        [self.aboveViewController.view removeFromSuperview];
        [self.context completeTransition:!self.context.transitionWasCancelled];

        if (self.isAllowsAppearanceTransition) {
            [self.belowViewController endAppearanceTransition];
        }
    }];
}

#pragma mark - Protected Methods

- (void)clearSourceImageView {
    [sourceImageView removeFromSuperview];
    sourceImageView = nil;
}
- (void)completeSource {
    if (_source.completion) {
        _source.completion();
    }
    [self clearSourceImageView];
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

#pragma mark - Private Methods

- (CGFloat)angle {
    if (![_source respondsToSelector:@selector(rotation)] || !_source.rotation) {
        return 0;
    }
    CGFloat rotation = _source.rotation();
    return rotation != 0 ? rotation * M_PI / 180 : 0;
}

- (void)animateDismission {
    self.aboveViewController.view.alpha = 0;

    if (self.isAllowsDeactivating) {
        self.belowViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        self.belowViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    }
    
    sourceImageView.layer.transform = CATransform3DMakeRotation(self.angle, 0, 0, 1);
    sourceImageView.frame = _source.to();
}

- (void)cancel:(void(^)(void))block {
    if (self.presenting) {
        [self.aboveViewController.view removeFromSuperview];
    } else {
        self.belowViewController.view.hidden = YES;
    }

    if (self.isAllowsAppearanceTransition) {
        [self.belowViewController endAppearanceTransition];
    }
    
    dispatch_after_sec(0.05, ^{
        [self.context completeTransition:!self.context.transitionWasCancelled];
        [self->sourceImageView removeFromSuperview];
        self->sourceImageView = nil;
        
        if (block) {
            block();
        }
    });
}

- (void)completion:(void(^)(void))block {
    if (_source.completion) {
        _source.completion();
    }

    [self.context completeTransition:!self.context.transitionWasCancelled];
    
    if (block) {
        block();
    }
    
    [self->sourceImageView removeFromSuperview];
    [self clear];
}

@end
