//
//  PanningInteractiveTransition.h
//  UIViewControllerTransitions
//
//  Created by pisces on 11/04/2017.
//
//

#import <UIKit/UIKit.h>
#import "AbstractInteractiveTransition.h"

@interface PanningInteractiveTransition : AbstractInteractiveTransition
@property (nonnull, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@end
