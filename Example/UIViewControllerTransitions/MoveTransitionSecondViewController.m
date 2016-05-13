//
//  MoveTransitionSecondViewController.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/13/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "MoveTransitionSecondViewController.h"

@interface MoveTransitionSecondViewController ()

@end

@implementation MoveTransitionSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Move Transition Second View";
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)]];
}

#pragma mark - UIBarButtonItem selector

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
