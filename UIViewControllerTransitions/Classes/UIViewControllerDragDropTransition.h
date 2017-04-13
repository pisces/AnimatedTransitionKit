//
//  UIViewControllerDragDropTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "AbstractUIViewControllerTransition.h"
#import "AnimatedDragDropTransitioning.h"
#import "UIMaskedImageView.h"

@protocol UIViewControllerDragDropTransitionDataSource;

@interface UIViewControllerDragDropTransition : AbstractUIViewControllerTransition
{
@protected
    CGPoint originDismissionImageViewPoint;
    UIMaskedImageView *dismissionImageView;
}

@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *dismissionSource;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitioningSource *presentingSource;
@property (nullable, nonatomic, strong) UIImage *sourceImage;
@property (nullable, nonatomic, weak) id<UIViewControllerDragDropTransitionDataSource, UIViewControllerTransitionDataSource> dismissionDataSource;
@end

@protocol UIViewControllerDragDropTransitionDataSource <UIViewControllerTransitionDataSource>
@optional
- (UIImage * _Nullable)sourceImageForDismission;
- (CGRect)sourceImageRectForDismission;
@end
