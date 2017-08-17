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

#import "AbstractAnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"
#import "AnimatedNavigationTransitioning.h"
#import "AnimatedTransitioning.h"
#import "DragDropTransition.h"
#import "DragDropTransitioning.h"
#import "FadeTransition.h"
#import "FadeTransitioning.h"
#import "MoveTransition.h"
#import "MoveTransitioning.h"
#import "NavigationMoveTransition.h"
#import "NavigationMoveTransitioning.h"
#import "NavigationPanningInteractiveTransition.h"
#import "PanningInteractiveTransition.h"
#import "UIMaskedImageView.h"
#import "UINavigationControllerTransition.h"
#import "UIViewControllerAnimatedTransition.h"
#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitions.h"
#import "UIViewControllerTransitionsMacro.h"

FOUNDATION_EXPORT double UIViewControllerTransitionsVersionNumber;
FOUNDATION_EXPORT const unsigned char UIViewControllerTransitionsVersionString[];

