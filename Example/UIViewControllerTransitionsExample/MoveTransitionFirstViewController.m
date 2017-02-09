//
//  MoveTransitionFirstViewController.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "MoveTransitionFirstViewController.h"
#import "MoveTransitionSecondViewController.h"

@interface MoveTransitionFirstViewController ()

@end

@implementation MoveTransitionFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Move Transition First View";
}

- (IBAction)buttonClicked:(id)sender {
    MoveTransitionSecondViewController *controller = [[MoveTransitionSecondViewController alloc] initWithNibName:@"MoveTransitionSecondView" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transition = [[UIViewControllerMoveTransition alloc] init];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
