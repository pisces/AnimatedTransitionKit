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
{
    UINavigationController *secondNavigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Fade Transition First View";
    
    FadeTransitionSecondViewController *controller = [[FadeTransitionSecondViewController alloc] initWithNibName:@"FadeTransitionSecondView" bundle:[NSBundle mainBundle]];
    
    secondNavigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    secondNavigationController.modalPresentationStyle = UIModalPresentationCustom;
    
    PanningInteractiveTransition *presentingInteractor = [PanningInteractiveTransition new];
    [presentingInteractor attach:self presentViewController:secondNavigationController];
    
    PanningInteractiveTransition *dismissionInteractor = [PanningInteractiveTransition new];
    [dismissionInteractor attach:secondNavigationController presentViewController:nil];
    
    UIViewControllerFadeTransition *transition = [UIViewControllerFadeTransition new];
    transition.dismissionInteractor = dismissionInteractor;
    transition.presentingInteractor = presentingInteractor;
    
    secondNavigationController.transition = transition;
}

- (IBAction)buttonClicked:(id)sender {
    [self presentViewController:secondNavigationController animated:YES completion:nil];
}

@end
