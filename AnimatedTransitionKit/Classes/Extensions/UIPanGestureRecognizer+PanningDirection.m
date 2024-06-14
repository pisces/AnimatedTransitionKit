//
//  UIPanGestureRecognizer+PanningDirection.m
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 2021/10/17.
//

#import "UIPanGestureRecognizer+PanningDirection.h"

@implementation UIPanGestureRecognizer (PanningDirection)

BOOL PanningDirectionIsVertical(PanningDirection direction) {
    return direction == PanningDirectionUp || direction == PanningDirectionDown;
}

- (PanningDirection)panningDirection {
    CGPoint velocity = [self velocityInView:self.view];
    CGFloat ratio = UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width;
    BOOL vertical = fabs(velocity.y) > fabs(velocity.x * ratio);
    
    if (vertical) {
        if (velocity.y < 0) return PanningDirectionUp;
        if (velocity.y > 0) return PanningDirectionDown;
    }
    
    if (velocity.x > 0) return PanningDirectionRight;
    if (velocity.x < 0) return PanningDirectionLeft;
    
    return PanningDirectionNone;
}

@end
