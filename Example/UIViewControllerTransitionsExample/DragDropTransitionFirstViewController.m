//
//  DragDropTransitionFirstViewController.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "DragDropTransitionFirstViewController.h"
#import "DragDropTransitionSecondViewController.h"

@implementation DragDropTransitionFirstViewController
{
    __weak IBOutlet UIImageView *imageView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DragDrop Transition First View";
    imageView.image = [UIImage imageNamed:@"ex"];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void)tapped {
    DragDropTransitionSecondViewController *controller = [[DragDropTransitionSecondViewController alloc] initWithNibName:@"DragDropTransitionSecondView" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
//    PanningInteractiveTransition *presentingInteractor = [PanningInteractiveTransition new];
//    [presentingInteractor attach:self presentViewController:navigationController];
    
    PanningInteractiveTransition *dismissionInteractor = [PanningInteractiveTransition new];
    [dismissionInteractor attach:navigationController presentViewController:nil];
    
    UIViewControllerDragDropTransition *transition = [UIViewControllerDragDropTransition new];
    transition.sourceImage = imageView.image;
    transition.dismissionDelegate = controller;
    transition.dismissionDataSource = controller;
    transition.dismissionInteractor = dismissionInteractor;
//    transition.presentingInteractor = presentingInteractor;
    
    const CGFloat w = CGRectGetWidth(self.view.frame);
    const CGFloat statusBarHeight = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
    const CGFloat navigationBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    const CGRect bigRect = CGRectMake(0, statusBarHeight+navigationBarHeight, w, w);
    const CGRect smallRect = CGRectMake(CGRectGetMinX(imageView.frame), CGRectGetMinY(imageView.frame), CGRectGetWidth(imageView.frame), CGRectGetHeight(imageView.frame));
    
    transition.presentingSource = [[AnimatedDragDropTransitioningSource new] from:^CGRect{
        return smallRect;
    } to:^CGRect{
        return bigRect;
    } rotation:^CGFloat{
        return 0;
    } completion:^{
        imageView.hidden = YES;
        controller.imageView.hidden = NO;
    }];
    
    transition.dismissionSource = [[AnimatedDragDropTransitioningSource new] from:^CGRect{
        return bigRect;
    } to:^CGRect{
        return smallRect;
    } rotation:^CGFloat{
        return 0;
    } completion:^{
        imageView.hidden = NO;
    }];
    
    navigationController.transition = transition;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
