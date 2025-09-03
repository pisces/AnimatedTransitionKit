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
//  AbstractInteractiveTransition.m
//  AnimatedTransitionKit
//
//  Created by pisces on 13/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedTransitionKit/AnimatedTransitionKit-Swift.h"
#import "AbstractInteractiveTransition.h"
#import "AnimatedTransitionKit.h"

@implementation AbstractInteractiveTransition
@synthesize terminating = _terminating;

#pragma mark - Properties

- (BOOL)isAppearing {
    return _viewControllerForAppearing != nil;
}

- (BOOL)isVertical {
    return _direction == InteractiveTransitionDirectionVertical;
}

- (UIViewController *)currentViewController {
    return self.isAppearing ? _viewControllerForAppearing : _viewController;
}

#pragma mark - Con(De)structor

- (id)init {
    self = [super init];
    if (self) {
        _shouldBeginWhenGestureChanged = YES;
        _direction = InteractiveTransitionDirectionVertical;
    }
    return self;
}

- (void)dealloc {
    [self detach];
    [self clear];
}

#pragma mark - Overridden: UIPercentDrivenInteractiveTransition

- (void)cancelInteractiveTransition {
    _terminating = YES;

    id<InteractiveTransitionDelegate> delegate = _delegate;
    AbstractTransition *transition = _transition;
    
    [super cancelInteractiveTransition];

    if (!transition.transitioning.context) {
        [transition endInteration];
        _terminating = NO;
        return;
    }

    if ([delegate respondsToSelector:@selector(willCancelWithInteractor:)]) {
        [delegate willCancelWithInteractor:self];
    }

    [transition interactionCancelled:self completion:^{
        [self completeInteraction:delegate transition:transition];
    }];
}

- (void)finishInteractiveTransition {
    _terminating = YES;

    id<InteractiveTransitionDelegate> delegate = _delegate;
    AbstractTransition *transition = _transition;

    [super finishInteractiveTransition];

    if ([delegate respondsToSelector:@selector(willCompleteWithInteractor:)]) {
        [delegate willCompleteWithInteractor:self];
    }

    [transition interactionCompleted:self completion:^{
        [self completeInteraction:delegate transition:transition];
    }];
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [super startInteractiveTransition:transitionContext];

    [self.transition interactionBegan:self transitionContext:transitionContext];

    if ([_delegate respondsToSelector:@selector(didBeginWithInteractor:)]) {
        [_delegate didBeginWithInteractor:self];
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    [super updateInteractiveTransition:percentComplete];

    [self.transition interactionChanged:self percent:percentComplete];

    if ([_delegate respondsToSelector:@selector(didChangeWithInteractor:percent:)]) {
        [_delegate didChangeWithInteractor:self percent:percentComplete];
    }
}

#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizerShouldBegin:)]) {
        return [_delegate interactor:self gestureRecognizerShouldBegin:gestureRecognizer];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldReceiveTouch:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldRequireFailureOfGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldRequireFailureOfGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([_delegate respondsToSelector:@selector(interactor:gestureRecognizer:shouldBeRequiredToFailByGestureRecognizer:)]) {
        return [_delegate interactor:self gestureRecognizer:gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:otherGestureRecognizer];
    }
    return NO;
}

#pragma mark - Public

- (CGFloat)percentForCompletion {
    return 0.15;
}

- (void)attach:(__weak UIViewController * _Nonnull)viewController {
    if ([viewController isEqual:_viewController]) {
        return;
    }
    if (_viewController) {
        [self detach];
    }
    _viewController = viewController;
    [_viewController.view addGestureRecognizer:self.gestureRecognizer];
}

- (void)detach {
    [self.gestureRecognizer.view removeGestureRecognizer:self.gestureRecognizer];
    _viewController = nil;
}

- (void)clear {
    if (!_viewControllerForAppearing.parentViewController) {
        _viewControllerForAppearing = nil;
    }
}

#pragma mark - Private methods

- (void)completeInteraction:(id<InteractiveTransitionDelegate>)delegate transition:(AbstractTransition *)transition {
    [transition endInteration];
    _terminating = NO;

    if (self.shouldComplete) {
        if ([delegate respondsToSelector:@selector(didCompleteWithInteractor:)]) {
            [delegate didCompleteWithInteractor:self];
        }
    } else {
        if ([delegate respondsToSelector:@selector(didCancelWithInteractor:)]) {
            [delegate didCancelWithInteractor:self];
        }
    }
}

@end
