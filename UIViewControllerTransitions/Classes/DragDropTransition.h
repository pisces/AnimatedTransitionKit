//
//  DragDropTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerDragDropTransition to DragDropTransition
//

#import "AbstractUIViewControllerTransition.h"
#import "AnimatedDragDropTransitioning.h"
#import "UIMaskedImageView.h"

@protocol DragDropTransitionDataSource;

@interface DragDropTransition : AbstractUIViewControllerTransition
@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *dismissionSource;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *presentingSource;
@end
