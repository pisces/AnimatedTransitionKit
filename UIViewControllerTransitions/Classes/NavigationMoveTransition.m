//
//  NavigationMoveTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/13/17.
//
//

#import "NavigationMoveTransition.h"
#import "NavigationMoveTransitioning.h"

@implementation NavigationMoveTransition

#pragma mark - Overridden: UINavigationControllerTransition

- (AnimatedNavigationTransitioning *)transitioningForPop {
    return [NavigationMoveTransitioning new];
}

- (AnimatedNavigationTransitioning *)transitioningForPush {
    return [NavigationMoveTransitioning new];
}

@end
