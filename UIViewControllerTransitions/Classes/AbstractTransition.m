//
//  AbstractTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "AbstractTransition.h"

@implementation AbstractTransition

#pragma mark - Con(De)structor

- (id)init {
    self = [super init];
    if (self) {
        [self initProperties];
    }
    return self;
}

#pragma mark - Public methods

- (void)clear {
    [_transitioning clear];
}

#pragma mark - Protected methods

- (void)initProperties {
}

@end