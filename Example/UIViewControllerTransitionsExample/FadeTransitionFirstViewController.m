//
//  FadeTransitionFirstViewController.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "FadeTransitionFirstViewController.h"
#import "FadeTransitionSecondViewController.h"

@implementation FadeTransitionFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Fade Transition First View";
}

- (IBAction)buttonClicked:(id)sender {
    FadeTransitionSecondViewController *controller = [[FadeTransitionSecondViewController alloc] initWithNibName:@"FadeTransitionSecondView" bundle:[NSBundle mainBundle]];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    navigationController.transition = [[UIViewControllerFadeTransition alloc] init];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
