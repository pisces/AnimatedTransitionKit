//
//  UIViewControllerDragDropTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//
//

#import "UIViewControllerDragDropTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation UIViewControllerDragDropTransition

@synthesize dismissionDataSource = _dismissionDataSource;

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (void)initProperties {
    [super initProperties];
    
    _imageViewContentMode = UIViewContentModeScaleAspectFill;
}

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    AnimatedDragDropTransitioning *transitioning = [AnimatedDragDropTransitioning new];
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.transitionSource = _dismissionSource;
    transitioning.dismissionImageView = dismissionImageView;
    transitioning.duration = self.durationForDismission;
    
    if ([_dismissionDataSource respondsToSelector:@selector(sourceImageForDismission)]) {
        transitioning.sourceImage = [_dismissionDataSource sourceImageForDismission];
    }
    
    dismissionImageView = nil;
    
    return transitioning;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedDragDropTransitioning *transitioning = [AnimatedDragDropTransitioning new];
    transitioning.presenting = YES;
    transitioning.duration = self.durationForPresenting;
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.transitionSource =_presentingSource;
    transitioning.sourceImage = _sourceImage;
    return transitioning;
}

@end
