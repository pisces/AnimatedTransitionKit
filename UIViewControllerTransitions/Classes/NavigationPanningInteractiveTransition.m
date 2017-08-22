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

- (AbstractTransition *)transition {
    return self.navigationController.navigationTransition;
}

- (BOOL)beginInteractiveTransition {
    if ([self.transition isAppearingWithInteractor:self]) {
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

- (BOOL)isInteractionEnabled {
    if ([self.transition isAppearingWithInteractor:self]) {
        return self.presentViewController && ![self.navigationController.viewControllers containsObject:self.presentViewController];
    }
    return self.navigationController.viewControllers.count > 1;
}

- (UINavigationController *)navigationController {
    if ([self.viewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *) self.viewController;
    }
    return nil;
}

@end
