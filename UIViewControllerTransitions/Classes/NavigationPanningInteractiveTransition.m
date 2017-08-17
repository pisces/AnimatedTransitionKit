//
//  NavigationPanningInteractiveTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/16/17.
//
//

#import "NavigationPanningInteractiveTransition.h"
#import "UINavigationControllerTransition.h"

@interface NavigationPanningInteractiveTransition ()
@property (nullable, nonatomic, readonly) UINavigationController *navigationController;
@end

@implementation NavigationPanningInteractiveTransition

#pragma mark - Overridden: PanningInteractiveTransition

- (UIViewControllerAnimatedTransition *)transition {
    return self.navigationController.navigationTransition;
}

- (BOOL)beginInteractiveTransition {
    if (self.isAppearing) {
        if (!self.presentViewController || [self.navigationController.viewControllers containsObject:self.presentViewController]) {
            return NO;
        }
        [self.navigationController pushViewController:self.presentViewController animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

#pragma mark - Properties

- (UINavigationController *)navigationController {
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *) self.viewController;
    }
    return nil;
}

@end
