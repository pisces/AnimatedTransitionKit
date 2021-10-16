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
    self.contentOffset = CGPointMake(self.contentOffset.x, self.contentSize.height - self.bounds.size.height + self.extAdjustedContentInset.bottom);
}

- (void)extScrollsToTop {
    self.contentOffset = CGPointMake(self.contentOffset.x, -self.extAdjustedContentInset.top);
}

@end
