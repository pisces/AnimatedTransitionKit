//
//  UIViewController+UIViewControllerTransitions.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "UIViewController+UIViewControllerTransitions.h"
#import <objc/runtime.h>

static void *AssociatedKeyTransition = @"transition";

@implementation UIViewController (UIViewControllerTransitions)

- (void)setTransition:(UIViewControllerTransition *)transition {
    if ([transition isEqual:[self transition]])
        return;
    
    transition.viewController = self;
    
    objc_setAssociatedObject(self, &AssociatedKeyTransition, transition, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewControllerTransition *)transition {
    return objc_getAssociatedObject(self, &AssociatedKeyTransition);
}

@end
