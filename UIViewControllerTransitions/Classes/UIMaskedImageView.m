//
//  UIMaskedImageView.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//

#import "UIMaskedImageView.h"

@implementation UIMaskedImageView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CAAnimation* animation = [self.layer animationForKey:@"bounds"];
    if (animation) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:animation.duration];
    }
    
    self.layer.mask.bounds = self.layer.bounds;
    if (animation) {
        [CATransaction commit];
    }
}

@end
