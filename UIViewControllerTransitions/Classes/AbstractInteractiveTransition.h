//
//  AbstractInteractiveTransition.h
//  UIViewControllerTransitions
//
//  Created by pisces on 13/04/2017.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, InteractiveTransitionDirection) {
    InteractiveTransitionDirectionVertical,
    InteractiveTransitionDirectionHorizontal
};

@interface AbstractInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonatomic) InteractiveTransitionDirection direction;
@property (nonatomic) CGPoint beginPoint;
@property (nonatomic) CGPoint beginViewPoint;
@property (nonatomic) CGPoint point;
@property (nullable, readonly) UIViewController *presentViewController;
@property (nonnull, readonly) UIViewController *viewController;
@property (nonnull, readonly) UIViewController *currentViewController;
- (void)attach:(__weak UIViewController * _Nonnull)viewController presentViewController:(__weak UIViewController * _Nullable)presentViewController;
- (void)detach;
@end
