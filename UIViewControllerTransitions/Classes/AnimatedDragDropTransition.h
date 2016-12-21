//
//  AnimatedDragDropTransition.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import "AnimatedTransition.h"
#import "UIMaskedImageView.h"

typedef CGRect (^AnimatedDragDropTransitionSourceBlock)(void);
typedef void (^AnimatedDragDropTransitionCompletionBlock)(void);
typedef CGFloat (^AnimatedDragDropTransitionValueBlock)(void);

@interface AnimatedDragDropTransitionSource: NSObject;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitionSourceBlock from;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitionSourceBlock to;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitionValueBlock rotation;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitionCompletionBlock completion;
- (void)clear;
- (AnimatedDragDropTransitionSource * _Nonnull)from:(_Nonnull AnimatedDragDropTransitionSourceBlock)from
                                                 to:(_Nonnull AnimatedDragDropTransitionSourceBlock)to
                                           rotation:(_Nullable AnimatedDragDropTransitionValueBlock)rotation
                                         completion:(_Nullable AnimatedDragDropTransitionCompletionBlock)completion;
@end

@protocol AnimatedDragDropTransitionProtected <NSObject>
- (void)clear;
- (UIMaskedImageView *_Nonnull)createImageView;
@end

@interface AnimatedDragDropTransition : AnimatedTransition <AnimatedDragDropTransitionProtected>
@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nonnull, nonatomic, strong) AnimatedDragDropTransitionSource *transitionSource;
@property (nonnull, nonatomic, strong) UIImage *sourceImage;
@property (nonnull, nonatomic, strong) UIImageView *dismissiontImageView;
@end
