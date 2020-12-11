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

#import "AbstractTransition.h"
#import "UINavigationControllerTransition.h"
#import "UIViewControllerTransition.h"
#import "UIViewControllerTransitionOptions.h"
#import "UIViewControllerTransitions.h"
#import "UIViewControllerTransitionsMacro.h"
#import "AbstractInteractiveTransition.h"
#import "NavigationPanningInteractiveTransition.h"
#import "PanningInteractiveTransition.h"
#import "AbstractAnimatedTransitioning.h"
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
#import "UIMaskedImageView.h"

FOUNDATION_EXPORT double UIViewControllerTransitionsVersionNumber;
FOUNDATION_EXPORT const unsigned char UIViewControllerTransitionsVersionString[];

