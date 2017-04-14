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

@protocol DragDropInteractiveTransitionDataSource;

@interface DragDropTransition : AbstractUIViewControllerTransition
{
@protected
    CGPoint originDismissionImageViewPoint;
    UIMaskedImageView *dismissionImageView;
}

@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *dismissionSource;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *presentingSource;
@property (nullable, nonatomic, strong) UIImage *sourceImage;
@property (nullable, nonatomic, weak) id<DragDropInteractiveTransitionDataSource, InteractiveTransitionDataSource> interactionDataSource;
@end

@protocol DragDropInteractiveTransitionDataSource <InteractiveTransitionDataSource>
@optional
- (UIImage * _Nullable)sourceImageForInteraction;
- (CGRect)sourceImageRectForInteraction;
@end
