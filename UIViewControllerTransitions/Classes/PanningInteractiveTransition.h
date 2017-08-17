//
//  PanningInteractiveTransition.h
//  UIViewControllerTransitions
//
//  Created by pisces on 11/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import <UIKit/UIKit.h>
#import "AbstractInteractiveTransition.h"

@protocol PanningInteractiveTransitionProtected <NSObject>
- (BOOL)beginInteractiveTransition;
@end

@interface PanningInteractiveTransition : AbstractInteractiveTransition <PanningInteractiveTransitionProtected>
@end

typedef NS_ENUM(NSUInteger, PanningDirection) {
    PanningDirectionNone,
    PanningDirectionUp,
    PanningDirectionDown,
    PanningDirectionLeft,
    PanningDirectionRight
};

@interface UIPanGestureRecognizer (UIViewControllerTransitions)
@property (nonatomic, readonly) PanningDirection panningDirection;
@end
