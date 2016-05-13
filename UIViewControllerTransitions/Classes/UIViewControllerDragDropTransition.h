//
//  UIViewControllerDragDropTransition.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "AbstractUIViewControllerTransition.h"
#import "AnimatedDragDropTransition.h"
#import "UIMaskedImageView.h"

@protocol UIViewControllerDragDropTransitionDataSource;

@interface UIViewControllerDragDropTransition : AbstractUIViewControllerTransition
{
@protected
    CGPoint originDismissionImageViewPoint;
    UIMaskedImageView *dismissionImageView;
}

@property (nullable, nonatomic, strong) AnimatedDragDropTransitionSource *dismissionSource;
@property (nullable, nonatomic, strong) AnimatedDragDropTransitionSource *presentingSource;
@property (nullable, nonatomic, strong) UIImage *sourceImage;
@property (nullable, nonatomic, weak) id<UIViewControllerDragDropTransitionDataSource, UIViewControllerTransitionDataSource> dismissionDataSource;
@end

@protocol UIViewControllerDragDropTransitionDataSource <UIViewControllerTransitionDataSource>
@optional
- (UIImage * _Nonnull)sourceImageForDismission;
- (CGRect)sourceImageRectForDismission;
@end