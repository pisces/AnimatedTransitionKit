//
//  MoveTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerMoveTransition to MoveTransition
//
//

#import <UIViewControllerTransitions/UIViewControllerTransitions.h>
#import "AnimatedMoveTransitioning.h"

@interface MoveTransition : AbstractUIViewControllerTransition
@property (nonatomic) MoveTransitioningDirection direction;
@end
