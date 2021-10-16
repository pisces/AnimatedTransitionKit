//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2021, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
