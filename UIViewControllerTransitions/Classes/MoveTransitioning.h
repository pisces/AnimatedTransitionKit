//
//  MoveTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedMoveTransitioning to MoveTransitioning
//

#import "AnimatedTransitioning.h"
#import "PanningInteractiveTransition.h"

typedef NS_ENUM(NSUInteger, MoveTransitioningDirection) {
    MoveTransitioningDirectionLeft = 1,
    MoveTransitioningDirectionUp,
    MoveTransitioningDirectionRight,
    MoveTransitioningDirectionDown
};

@interface MoveTransitioning : AnimatedTransitioning
@property (nonatomic) MoveTransitioningDirection direction;
@end
