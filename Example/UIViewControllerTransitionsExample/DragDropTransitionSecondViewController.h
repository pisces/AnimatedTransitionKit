//
//  DragDropViewController.h
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIViewControllerTransitions/UIViewControllerTransitions.h>

@interface DragDropTransitionSecondViewController : UIViewController <UIViewControllerDragDropTransitionDataSource, UIViewControllerTransitionDelegate>
@property (nullable, nonatomic, weak) IBOutlet UIImageView *imageView;
@end
