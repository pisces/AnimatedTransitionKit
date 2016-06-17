//
//  DemoViewController.m
//  ModalTransitionAnimator
//
//  Created by Steve Kim on 05/12/2016.
//  Copyright (c) 2016 Steve Kim. All rights reserved.
//

#import "DemoViewController.h"
#import "DragDropTransitionFirstViewController.h"
#import "MoveTransitionFirstViewController.h"
#import "FadeTransitionFirstViewController.h"

@interface DemoViewController ()

@end

@implementation DemoViewController
{
    NSArray<NSString *> *exampleTitles;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"UIViewController Transitions Demo";
    exampleTitles = @[@"UIViewController DragDrop Transition", @"UIViewController Move Transition", @"UIViewController Fade Transition"];
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - UITableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return exampleTitles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    cell.textLabel.text = exampleTitles[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller;
    
    if (indexPath.row == 0) {
        controller = [[DragDropTransitionFirstViewController alloc] initWithNibName:@"DragDropTransitionFirstView" bundle:[NSBundle mainBundle]];
    } else if (indexPath.row == 1) {
        controller = [[MoveTransitionFirstViewController alloc] initWithNibName:@"MoveTransitionFirstView" bundle:[NSBundle mainBundle]];
    } else if (indexPath.row == 2) {
        controller = [[FadeTransitionFirstViewController alloc] initWithNibName:@"FadeTransitionFirstView" bundle:[NSBundle mainBundle]];
    }
    
    [self.navigationController pushViewController:controller animated:YES];
}

@end