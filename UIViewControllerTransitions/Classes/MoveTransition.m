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
#import "PanningInteractiveTransition.h"

@implementation MoveTransition

#pragma mark - Properties

- (BOOL)interactiveTransitionDirection {
    return (_direction == MoveTransitioningDirectionLeft || _direction == MoveTransitioningDirectionRight) ? InteractiveTransitionDirectionHorizontal : InteractiveTransitionDirectionVertical;
}

- (void)setDirection:(MoveTransitioningDirection)direction {
    if (direction == _direction) {
        return;
    }
    
    _direction = direction;
    self.dismissionInteractor.direction = self.presentingInteractor.direction = self.interactiveTransitionDirection;
}

#pragma mark - Overridden: UIViewControllerTransition

- (BOOL)isAppearingWithInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    if (_direction == MoveTransitioningDirectionUp) {
        return direction == PanningDirectionUp;
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return direction == PanningDirectionDown;
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return direction == PanningDirectionLeft;
    }
    return direction == PanningDirectionRight;
}

- (BOOL)isValidWithInteractor:(AbstractInteractiveTransition *)interactor {
    if (![interactor isKindOfClass:[PanningInteractiveTransition class]]) {
        return NO;
    }
    
    PanningDirection direction = ((PanningInteractiveTransition *) interactor).panningDirection;
    if (_direction == MoveTransitioningDirectionUp) {
        return interactor.isAppearing ? direction == PanningDirectionUp : direction == PanningDirectionDown;
    }
    if (_direction == MoveTransitioningDirectionDown) {
        return interactor.isAppearing ? direction == PanningDirectionDown : direction == PanningDirectionUp;
    }
    if (_direction == MoveTransitioningDirectionLeft) {
        return interactor.isAppearing ? direction == PanningDirectionLeft : direction == PanningDirectionRight;
    }
    return interactor.isAppearing ? direction == PanningDirectionRight : direction == PanningDirectionLeft;
}

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
