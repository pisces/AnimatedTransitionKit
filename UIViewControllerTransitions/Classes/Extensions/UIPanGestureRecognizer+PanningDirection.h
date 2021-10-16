//
//  UIPanGestureRecognizer+PanningDirection.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2021/10/17.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PanningDirection) {
    PanningDirectionNone,
    PanningDirectionUp,
    PanningDirectionDown,
    PanningDirectionLeft,
    PanningDirectionRight
};

BOOL PanningDirectionIsVertical(PanningDirection direction);

@interface UIPanGestureRecognizer (PanningDirection)
@property (nonatomic, readonly) PanningDirection panningDirection;
@end
