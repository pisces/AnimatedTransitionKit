//
//  UIViewControllerAnimatedTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "UIViewControllerAnimatedTransition.h"

@implementation UIViewControllerAnimatedTransition

#pragma mark - Con(De)structor

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransition protocol

- (void)setAllowsInteraction:(BOOL)allowsInteraction {
    if (allowsInteraction == _allowsInteraction) {
        return;
    }
    
    _allowsInteraction = allowsInteraction;
}

- (void)clear {
    [_transitioning clear];
}

#pragma mark - Protected methods

- (void)initProperties {
}

@end
