//
//  MoveTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerMoveTransition to MoveTransition
//
//

#import "MoveTransition.h"
#import "AnimatedMoveTransitioning.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation MoveTransition

#pragma mark - Properties

- (void)setDirection:(MoveTransitioningDirection)direction {
    if (direction == _direction) {
        return;
    }
    
    _direction = direction;
    self.dismissionInteractor.direction = self.presentingInteractor.direction = (direction == MoveTransitioningDirectionLeft || direction == MoveTransitioningDirectionRight) ? InteractiveTransitionDirectionHorizontal : InteractiveTransitionDirectionVertical;
}

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (id)init {
    self = [super init];
    if (self) {
        _direction = MoveTransitioningDirectionUp;
    }
    return self;
}

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    AnimatedMoveTransitioning *transitioning = [AnimatedMoveTransitioning new];
    transitioning.direction = _direction;
    transitioning.duration = self.durationForDismission;
    return transitioning;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedMoveTransitioning *transitioning = [AnimatedMoveTransitioning new];
    transitioning.direction = _direction;
    transitioning.duration = self.durationForPresenting;
    transitioning.presenting = YES;
    return transitioning;
}

@end
