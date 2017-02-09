//
//  FadeTransitionSecondViewController.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 6/18/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "FadeTransitionSecondViewController.h"

@implementation FadeTransitionSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Fade Transition Second View";
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)]];
}

#pragma mark - UIBarButtonItem selector

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
