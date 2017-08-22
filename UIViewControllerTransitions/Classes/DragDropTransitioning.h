//
//  DragDropTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//  Modified by Steve Kim on 8/13/17.
//      - Rename AnimatedDragDropTransitioning to DragDropTransitioning
//

#import "AnimatedTransitioning.h"
#import "UIMaskedImageView.h"

typedef void (^DragDropTransitioningCompletionBlock)(void);
typedef UIImage * _Nullable (^DragDropTransitioningImageBlock)(void);
typedef CGRect (^DragDropTransitioningSourceBlock)(void);
typedef CGFloat (^DragDropTransitioningValueBlock)(void);

@interface DragDropTransitioningSource: NSObject;
@property (nullable, nonatomic, copy) DragDropTransitioningImageBlock image;
@property (nullable, nonatomic, copy) DragDropTransitioningSourceBlock from;
@property (nullable, nonatomic, copy) DragDropTransitioningSourceBlock to;
@property (nullable, nonatomic, copy) DragDropTransitioningValueBlock rotation;
@property (nullable, nonatomic, copy) DragDropTransitioningCompletionBlock completion;
+ (DragDropTransitioningSource * _Nonnull)image:(_Nonnull DragDropTransitioningImageBlock)image
                                                   from:(_Nonnull DragDropTransitioningSourceBlock)from
                                                     to:(_Nonnull DragDropTransitioningSourceBlock)to
                                               rotation:(_Nullable DragDropTransitioningValueBlock)rotation
                                             completion:(_Nullable DragDropTransitioningCompletionBlock)completion;
- (void)clear;
@end

@protocol DragDropTransitioningProtected <NSObject>
- (void)clear;
- (UIMaskedImageView *_Nonnull)createImageView;
@end

@interface DragDropTransitioning : AnimatedTransitioning <DragDropTransitioningProtected>
@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nonnull, nonatomic, strong) DragDropTransitioningSource *source;
@end
