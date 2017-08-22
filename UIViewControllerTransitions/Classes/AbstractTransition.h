//
//  AbstractTransition.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import "AbstractAnimatedTransitioning.h"
#import "AbstractInteractiveTransition.h"

@protocol AbstractTransitionProtected <NSObject>
- (void)initProperties;
@end

@interface AbstractTransition: NSObject <AbstractTransitionProtected>
@property (nonatomic, getter=isAllowsInteraction) BOOL allowsInteraction;
@property (nonatomic, getter=isInteractionEnabled) BOOL interactionEnabled;
@property (nullable, nonatomic, readonly) AbstractInteractiveTransition *currentInteractor;
@property (nullable, nonatomic, readonly) AbstractAnimatedTransitioning *transitioning;
- (void)clear;
- (BOOL)isAppearingWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
- (BOOL)isValidWithInteractor:(AbstractInteractiveTransition * _Nonnull)interactor;
@end
