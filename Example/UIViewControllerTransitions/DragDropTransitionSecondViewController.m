//
//  DragDropViewController.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 5/12/16.
//  Copyright © 2016 Steve Kim. All rights reserved.
//

#import "DragDropTransitionSecondViewController.h"

@interface DragDropTransitionSecondViewController ()
@end

@implementation DragDropTransitionSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DragDrop Transition Second View";
    _imageView.hidden = YES;
    _imageView.image = [UIImage imageNamed:@"ex"];
    NSLayoutConstraint *constraint = [NSLayoutConstraint
                                      constraintWithItem:_imageView
                                      attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:_imageView
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1
                                      constant:0];
    
    [_imageView addConstraint:constraint];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)]];
}

#pragma mark - UIViewControllerTransition delegate

- (void)didBeginTransition {
    _imageView.hidden = YES;
}

- (void)didEndTransition {
    _imageView.hidden = NO;
}

#pragma mark - UIViewControllerDragDropTransition data source

- (UIImage *)sourceImageForDismission {
    return _imageView.image;
}

- (CGRect)sourceImageRectForDismission {
    return _imageView.frame;
}

#pragma mark - UIBarButtonItem selector

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
