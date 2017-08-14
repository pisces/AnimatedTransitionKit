//
//  UIViewController+UIViewControllerTransitions.h
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 8/14/17.
//
//

#import <UIKit/UIKit.h>
#import "UIViewControllerTransition.h"

@interface UIViewController (UIViewControllerTransitions)
@property (nullable, nonatomic, weak) UIViewControllerTransition *transition;
@end
