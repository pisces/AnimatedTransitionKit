//
//  PanningInteractiveTransition.h
//  Pods
//
//  Created by pisces on 11/04/2017.
//
//

#import <UIKit/UIKit.h>

@interface PanningInteractiveTransition : UIPercentDrivenInteractiveTransition
@property (nonnull, readonly) UIPanGestureRecognizer *panGestureRecognizer;
- (void)attach:(UIViewController * _Nonnull)viewController presentViewController:(UIViewController * _Nonnull)presentViewController;
- (void)detach;
@end
