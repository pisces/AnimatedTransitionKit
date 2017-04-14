//
//  AnimatedDragDropTransitioning.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//

#import "AnimatedTransitioning.h"
#import "UIMaskedImageView.h"

typedef CGRect (^AnimatedDragDropTransitioningSourceBlock)(void);
typedef void (^AnimatedDragDropTransitioningCompletionBlock)(void);
typedef CGFloat (^AnimatedDragDropTransitioningValueBlock)(void);

@interface AnimatedDragDropTransitioningSource: NSObject;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitioningSourceBlock from;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitioningSourceBlock to;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitioningValueBlock rotation;
@property (nullable, nonatomic, copy) AnimatedDragDropTransitioningCompletionBlock completion;
- (void)clear;
- (AnimatedDragDropTransitioningSource * _Nonnull)from:(_Nonnull AnimatedDragDropTransitioningSourceBlock)from
                                                 to:(_Nonnull AnimatedDragDropTransitioningSourceBlock)to
                                           rotation:(_Nullable AnimatedDragDropTransitioningValueBlock)rotation
                                         completion:(_Nullable AnimatedDragDropTransitioningCompletionBlock)completion;
@end

@protocol AnimatedDragDropTransitioningProtected <NSObject>
- (void)clear;
- (UIMaskedImageView *_Nonnull)createImageView;
@end

@interface AnimatedDragDropTransitioning : AnimatedTransitioning <AnimatedDragDropTransitioningProtected>
@property (nonatomic) UIViewContentMode imageViewContentMode;
@property (nonnull, nonatomic, strong) AnimatedDragDropTransitioningSource *transitionSource;
@property (nonnull, nonatomic, strong) UIImage *sourceImage;
@property (nonnull, nonatomic, strong) UIImageView *dismissionImageView;
@end
