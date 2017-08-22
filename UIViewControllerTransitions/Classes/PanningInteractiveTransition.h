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

typedef NS_ENUM(NSUInteger, PanningDirection) {
    PanningDirectionNone,
    PanningDirectionUp,
    PanningDirectionDown,
    PanningDirectionLeft,
    PanningDirectionRight
};

BOOL PanningDirectionIsVertical(PanningDirection direction);

@protocol PanningInteractiveTransitionProtected <NSObject>
- (BOOL)beginInteractiveTransition;
@end

@interface PanningInteractiveTransition : AbstractInteractiveTransition <PanningInteractiveTransitionProtected>
@property (nonatomic, readonly) PanningDirection panningDirection;
@end

@interface UIPanGestureRecognizer (UIViewControllerTransitions)
@property (nonatomic, readonly) PanningDirection panningDirection;
@end
