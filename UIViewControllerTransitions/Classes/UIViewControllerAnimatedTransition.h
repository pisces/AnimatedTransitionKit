//
//  UIViewControllerAnimatedTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "AbstractAnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"

@protocol UIViewControllerAnimatedTransitionProtected <NSObject>
- (void)initProperties;
@end

@interface UIViewControllerAnimatedTransition: NSObject <UIViewControllerAnimatedTransitionProtected>
@property (nonatomic, getter=isAllowsInteraction) BOOL allowsInteraction;
@property (nonatomic, getter=isInteractionEnabled) BOOL interactionEnabled;
@property (nullable, nonatomic, readonly) AbstractInteractiveTransition *currentInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *dismissionInteractor;
@property (nullable, nonatomic, strong) AbstractInteractiveTransition *presentingInteractor;
@property (nullable, nonatomic, readonly) AbstractAnimatedTransitioning *transitioning;
- (void)clear;
@end
