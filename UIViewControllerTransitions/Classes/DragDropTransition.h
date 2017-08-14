//
//  DragDropTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerDragDropTransition to DragDropTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring extract methods
//

#import "UIViewControllerTransition.h"
#import "DragDropTransitioning.h"
#import "UIMaskedImageView.h"

@protocol DragDropTransitionDataSource;

@interface DragDropTransition : UIViewControllerTransition
@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nullable, nonatomic, strong) DragDropTransitioningSource *dismissionSource;
@property (nullable, nonatomic, strong) DragDropTransitioningSource *presentingSource;
@end
