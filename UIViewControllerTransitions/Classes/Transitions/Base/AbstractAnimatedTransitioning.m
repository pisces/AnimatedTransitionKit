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
//  AbstractAnimatedTransitioning.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//

#import "AbstractAnimatedTransitioning.h"

@implementation AbstractAnimatedTransitioning

#pragma mark - UIViewControllerAnimatedTransitioning protocol

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return _options.duration;
}

- (void)animationEnded:(BOOL)transitionCompleted {
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    _context = transitionContext;
    _fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    _toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
}

#pragma mark - Properties

- (CGFloat)completionBounds {
    return UIScreen.mainScreen.bounds.size.width/4;
}

- (CGFloat)heightRatio {
    return UIScreen.mainScreen.bounds.size.height/667;
}

- (CGFloat)widthRatio {
    return UIScreen.mainScreen.bounds.size.width/375;
}

- (UIViewController *)aboveViewController {
    return nil;
}

- (UIViewController *)belowViewController {
    return nil;
}

#pragma mark - Public methods

- (void)animate:(void (^)(void))animations
     completion:(void (^)(void))completion {
    [self animateWithDuration:_options.duration animations:animations completion:completion];
}

- (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void (^)(void))animations
                 completion:(void (^)(void))completion {
    if (_options.usingSpring) {
        [UIView animateWithDuration:_options.duration
                              delay:_options.delay
             usingSpringWithDamping:_options.usingSpringWithDamping
              initialSpringVelocity:_options.initialSpringVelocity
                            options:_options.animationOptions | UIViewAnimationOptionAllowUserInteraction
                         animations:animations
                         completion:^(BOOL finished) {
            completion();
        }];
    } else {
        [UIView animateWithDuration:_options.duration
                              delay:_options.delay
                            options:_options.animationOptions | UIViewAnimationOptionAllowUserInteraction
                         animations:animations
                         completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (void)clear {
    _fromViewController.view.alpha = 1;
    _fromViewController.view.transform = CGAffineTransformTranslate(self.fromViewController.view.transform, 0, 0);
    _fromViewController.view.hidden = NO;
}

- (void)endAnimating {
    _animating = NO;
    _percentOfInteraction = 0;
    _percentOfBounds = 0;
}

- (void)interactionBegan:(AbstractInteractiveTransition * _Nonnull)interactor transitionContext:(id <UIViewControllerContextTransitioning> _Nonnull)transitionContext {
    _context = transitionContext;
}

- (void)interactionCancelled:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (void)interactionChanged:(AbstractInteractiveTransition * _Nonnull)interactor percent:(CGFloat)percent {
    _percentOfInteraction = percent;
    
    [self updatePercentOfBounds];
}

- (void)interactionCompleted:(AbstractInteractiveTransition * _Nonnull)interactor completion:(void (^_Nullable)(void))completion {
}

- (BOOL)shouldTransition:(AbstractInteractiveTransition *)interactor {
    return YES;
}

- (void)startAnimating {
    _animating = YES;
}

- (void)updatePercentOfBounds {
    _percentOfBounds = _percentOfInteraction * (UIScreen.mainScreen.bounds.size.height / _completionBounds);
}

- (void)updateTranslationOffset:(AbstractInteractiveTransition *)interactor {
}

@end
