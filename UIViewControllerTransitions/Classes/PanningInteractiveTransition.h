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

@interface PanningInteractiveTransition : AbstractInteractiveTransition
@end

typedef NS_ENUM(NSUInteger, PanningDirection) {
    PanningDirectionNone,
    PanningDirectionUp,
    PanningDirectionDown,
    PanningDirectionLeft,
    PanningDirectionRight
};

@interface UIPanGestureRecognizer (pisces_UIViewControllerTransitions)
@property (nonatomic, readonly) PanningDirection panningDirection;
@end
