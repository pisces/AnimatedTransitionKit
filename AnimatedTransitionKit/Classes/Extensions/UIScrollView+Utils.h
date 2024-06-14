//
//  UIScrollView+Utils.h
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 2021/10/17.
//

#import <UIKit/UIScrollView.h>

@interface UIScrollView (Utils)
@property (nonatomic, readonly) UIEdgeInsets extAdjustedContentInset;
- (void)extScrollsToBottom;
- (void)extScrollsToTop;
@end
