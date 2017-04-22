//
//  AnimatedMoveTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedTransitioning.h"

typedef NS_ENUM(NSUInteger, MoveTransitioningDirection) {
    MoveTransitioningDirectionLeft = 1,
    MoveTransitioningDirectionUp,
    MoveTransitioningDirectionRight,
    MoveTransitioningDirectionDown
};

@interface AnimatedMoveTransitioning : AnimatedTransitioning
@property (nonatomic) MoveTransitioningDirection direction;
@end
