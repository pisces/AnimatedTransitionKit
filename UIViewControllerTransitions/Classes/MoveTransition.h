//
//  MoveTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerMoveTransition to MoveTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring extract methods
//
//

#import "UIViewControllerTransition.h"
#import "MoveTransitioning.h"

@interface MoveTransition : UIViewControllerTransition
@property (nonatomic) MoveTransitioningDirection direction;
@end
