//
//  MoveTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename UIViewControllerMoveTransition to MoveTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring design for 3.0.0
//
//

#import "MoveTransition.h"
#import "MoveTransitioning.h"
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

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    MoveTransitioning *transitioning = [MoveTransitioning new];
    transitioning.direction = _direction;
    return transitioning;
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    MoveTransitioning *transitioning = [MoveTransitioning new];
    transitioning.direction = _direction;
    return transitioning;
}

@end
