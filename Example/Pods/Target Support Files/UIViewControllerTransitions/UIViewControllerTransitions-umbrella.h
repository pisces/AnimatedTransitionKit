#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AbstractInteractiveTransition.h"
#import "AbstractUIViewControllerTransition.h"
#import "AnimatedDragDropTransitioning.h"
#import "AnimatedFadeTransitioning.h"
#import "AnimatedMoveTransitioning.h"
#import "AnimatedTransitioning.h"
#import "PanningInteractiveTransition.h"
#import "UIMaskedImageView.h"
#import "UIViewControllerDragDropTransition.h"
#import "UIViewControllerFadeTransition.h"
#import "UIViewControllerMoveTransition.h"
#import "UIViewControllerTransitions.h"
#import "UIViewControllerTransitionsMacro.h"

FOUNDATION_EXPORT double UIViewControllerTransitionsVersionNumber;
FOUNDATION_EXPORT const unsigned char UIViewControllerTransitionsVersionString[];

