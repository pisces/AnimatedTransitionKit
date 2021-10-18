//
//  UIScrollView+Utils.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2021/10/17.
//

#import "UIScrollView+Utils.h"
#import "UIPanGestureRecognizer+PanningDirection.h"

@implementation UIScrollView (Utils)

- (UIEdgeInsets)extAdjustedContentInset {
    if (@available(iOS 11.0, *)) {
        return self.adjustedContentInset;
    }
    return self.contentInset;
}

- (void)extScrollsToBottom {
    CGPoint point = CGPointMake(self.contentOffset.x, self.contentSize.height - self.bounds.size.height + self.extAdjustedContentInset.bottom);
    [self setContentOffset:point animated:NO];
}

- (void)extScrollsToTop {
    CGPoint point = CGPointMake(self.contentOffset.x, -self.extAdjustedContentInset.top);
    [self setContentOffset:point animated:NO];
}

@end
