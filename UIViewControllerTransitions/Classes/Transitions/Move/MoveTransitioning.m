//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2021, Steve Kim
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
//  MoveTransitioning.m
//  UIViewControllerTransitions
//
//  Created by pisces on 2015. 9. 24..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedMoveTransitioning to MoveTransitioning
//

#import "MoveTransitioning.h"
#import "PanningInteractiveTransition.h"
#import "UIScrollView+Utils.h"
#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation MoveTransitioning
@synthesize percentOfBounds = _percentOfBounds;

#pragma mark - Properties

- (BOOL)isVertical {
    return _direction == MoveTransitioningDirectionUp || _direction == MoveTransitioningDirectionDown;
}

- (CGAffineTransform)transformFrom {
    CGSize size = UIScreen.mainScreen.bounds.size;
    if (_direction == MoveTransitioningDirectionUp) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? size.height : 0);
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? -size.height : 0);
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return CGAffineTransformMakeTranslation(self.presenting ? size.width : 0, 0);
    }
    return CGAffineTransformMakeTranslation(self.presenting ? -size.width : 0, 0);
}

- (CGAffineTransform)transformTo {
    CGSize size = UIScreen.mainScreen.bounds.size;
    if (_direction == MoveTransitioningDirectionUp) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? 0 : size.height);
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return CGAffineTransformMakeTranslation(0, self.presenting ? 0 : -size.height);
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return CGAffineTransformMakeTranslation(self.presenting ? 0 : size.width, 0);
    }
    return CGAffineTransformMakeTranslation(self.presenting ? 0 : -size.width, 0);
}

#pragma mark - Overridden: AnimatedTransitioning

- (CGFloat)completionBounds {
    return ([self isVertical] ? UIScreen.mainScreen.bounds.size.height : UIScreen.mainScreen.bounds.size.width) / 4;
}

- (void)animateTransitionForDismission:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.isAllowsDeactivating) {
        self.toViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
    }
    self.toViewController.view.hidden = NO;
    self.fromViewController.view.transform = self.transformFrom;

    if (transitionContext.isInteractive) {
        return;
    }

    [self animate:^{
        if (self.isAllowsDeactivating) {
            self.toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
            self.toViewController.view.alpha = 1;
            self.toViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }
        self.fromViewController.view.transform = self.transformTo;
    } completion:^{
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [self.fromViewController.view removeFromSuperview];
        [self.belowViewController endAppearanceTransition];
    }];
}

- (void)animateTransitionForPresenting:(id<UIViewControllerContextTransitioning>)transitionContext {
    [super animateTransitionForPresenting:transitionContext];

    self.toViewController.view.transform = self.transformFrom;

    [transitionContext.containerView addSubview:self.toViewController.view];

    if (transitionContext.isInteractive) {
        return;
    }

    [self animate:^{
        self.toViewController.view.transform = self.transformTo;

        if (self.isAllowsDeactivating) {
            self.fromViewController.view.alpha = 0.5;
            self.fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            self.fromViewController.view.transform = CGAffineTransformMakeScale(0.94, 0.94);
        }
    } completion:^{
        if (self.isAllowsDeactivating) {
            self.fromViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }

        if (!transitionContext.transitionWasCancelled) {
            self.fromViewController.view.hidden = YES;
        }

        [self.belowViewController endAppearanceTransition];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)interactionBegan:(AbstractInteractiveTransition *)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    [super interactionBegan:interactor transitionContext:transitionContext];

    [self.belowViewController beginAppearanceTransition:!self.presenting animated:transitionContext.isAnimated];
    self.aboveViewController.view.transform = self.transformFrom;
    self.aboveViewController.view.hidden = NO;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 1 : 0.5;
    const CGFloat scale = self.presenting ? 1 : 0.94;

    [self animateWithDuration:0.25 animations:^{
        self.aboveViewController.view.transform = self.transformFrom;

        if (self.isAllowsDeactivating) {
            self.belowViewController.view.alpha = alpha;
            self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
            self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeNormal : UIViewTintAdjustmentModeDimmed;
        }
    } completion:^{
        if (self.isAllowsDeactivating) {
            self.belowViewController.view.transform = CGAffineTransformMakeScale(1, 1);
        }

        if (self.presenting) {
            [self.aboveViewController.view removeFromSuperview];
        }

        [self.context completeTransition:NO];
        completion();
    }];
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    [super interactionChanged:interactor percent:percent];

    PanningInteractiveTransition *panningInteractor = (PanningInteractiveTransition *) interactor;
    if (interactor.isVertical) {
        const CGFloat y = (self.transformFrom.ty + interactor.translation.y) - panningInteractor.translationOffset;
        self.aboveViewController.view.transform = CGAffineTransformMakeTranslation(0, [self restricted:y]);
    } else {
        const CGFloat x = (self.transformFrom.tx + interactor.translation.x) - panningInteractor.translationOffset;
        self.aboveViewController.view.transform = CGAffineTransformMakeTranslation([self restricted:x], 0);
    }

    if (self.isAllowsDeactivating) {
        CGFloat alpha = self.presenting ? 1 - ((1 - 0.5) * self.percentOfBounds) : 0.5 + ((1 - 0.5) * self.percentOfBounds);
        CGFloat scale = self.presenting ? 1 - ((1 - 0.94) * self.percentOfBounds) : 0.94 + ((1 - 0.94) * self.percentOfBounds);
        alpha = MAX(0.5, MIN(1, alpha));
        scale = MAX(0.94, MIN(1, scale));
        self.belowViewController.view.alpha = alpha;
        self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
    const CGFloat alpha = self.presenting ? 0.5 : 1;
    const CGFloat scale = self.presenting ? 0.94 : 1;

    [self animate:^{
        self.aboveViewController.view.transform = self.transformTo;

        if (self.isAllowsDeactivating) {
            self.belowViewController.view.alpha = alpha;
            self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
            self.belowViewController.view.tintAdjustmentMode = self.presenting ? UIViewTintAdjustmentModeDimmed : UIViewTintAdjustmentModeNormal;
        }
    } completion:^{
        if (self.isAllowsDeactivating) {
            self.belowViewController.view.alpha = alpha;
            self.belowViewController.view.transform = CGAffineTransformMakeScale(scale, scale);
        }

        if (self.presenting) {
            self.belowViewController.view.hidden = YES;
            [self.belowViewController endAppearanceTransition];
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
        } else {
            [self.context completeTransition:!self.context.transitionWasCancelled];
            completion();
            [self.aboveViewController.view removeFromSuperview];
            [self.belowViewController endAppearanceTransition];
        }
    }];
}

- (BOOL)shouldTransition:(AbstractInteractiveTransition *)interactor {
    PanningInteractiveTransition *panningInteractor = (PanningInteractiveTransition *) interactor;
    UIScrollView *scrollView = panningInteractor.drivingScrollView;

    switch (_direction) {
        case MoveTransitioningDirectionUp:
            switch (panningInteractor.panningDirection) {
                case PanningDirectionDown: {
                    BOOL shouldChange = scrollView.contentOffset.y + scrollView.extAdjustedContentInset.top <= 0;
                    if (shouldChange) {
                        [scrollView extScrollsToTop];
                    }
                    return shouldChange;
                }
                case PanningDirectionUp: {
                    BOOL shouldChange = panningInteractor.currentViewController.view.transform.ty > 0;
                    if (shouldChange) {
                        [scrollView extScrollsToTop];
                    }
                    return shouldChange;
                }
                default:
                    return NO;
            }
        case MoveTransitioningDirectionDown:
            switch (panningInteractor.panningDirection) {
                case PanningDirectionDown: {
                    BOOL shouldChange = panningInteractor.currentViewController.view.transform.ty < 0;
                    if (shouldChange) {
                        [scrollView extScrollsToBottom];
                    }
                    return shouldChange;
                }
                case PanningDirectionUp: {
                    CGFloat caculated = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.extAdjustedContentInset.bottom);
                    BOOL shouldChange = caculated >= 0;
                    if (shouldChange) {
                        [scrollView extScrollsToBottom];
                    }
                    return shouldChange;
                }
                default:
                    return NO;
            }
        default:
            return YES;
    }
}

- (void)updatePercentOfBounds {
    CGFloat multiply = _direction == MoveTransitioningDirectionUp || _direction == MoveTransitioningDirectionLeft ? 1 : -1;
    CGFloat bounds = self.isVertical ? UIScreen.mainScreen.bounds.size.height : UIScreen.mainScreen.bounds.size.width;
    _percentOfBounds = (self.percentOfInteraction * multiply) * (bounds / self.completionBounds);
}

- (void)updateTranslationOffset:(AbstractInteractiveTransition *)interactor {
    PanningInteractiveTransition *panningInteractor = (PanningInteractiveTransition *) interactor;
    UIScrollView *scrollView = panningInteractor.drivingScrollView;

    switch (_direction) {
        case MoveTransitioningDirectionUp:
            panningInteractor.translationOffset = scrollView.contentOffset.y + scrollView.extAdjustedContentInset.top;
            break;
        case MoveTransitioningDirectionDown: {
            panningInteractor.translationOffset = scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.extAdjustedContentInset.bottom);
            break;
        }
        default:
            panningInteractor.translationOffset = 0;
            break;
    }
}

#pragma mark - Private methods

- (CGFloat)restricted:(CGFloat)value {
    if (_direction == MoveTransitioningDirectionUp) {
        return MAX(0, value);
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return MIN(0, value);
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return MAX(0, value);
    }
    return MIN(0, value);
}

@end
