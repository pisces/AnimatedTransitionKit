//
//  DragDropTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerDragDropTransition to DragDropTransition
//

#import "DragDropTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation DragDropTransition

#pragma mark - Overridden: AbstractUIViewControllerTransition

- (void)initProperties {
    [super initProperties];
    
    self.animationOptionsForDismission = self.animationOptionsForPresenting = 7;
    _imageViewContentMode = UIViewContentModeScaleAspectFill;
}

- (AnimatedTransitioning *)animatedTransitioningForDismissedController:(UIViewController *)dismissed {
    AnimatedDragDropTransitioning *transitioning = [AnimatedDragDropTransitioning new];
    transitioning.duration = self.durationForDismission;
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.source = _dismissionSource;
    return transitioning;
}

- (AnimatedTransitioning *)animatedTransitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedDragDropTransitioning *transitioning = [AnimatedDragDropTransitioning new];
    transitioning.presenting = YES;
    transitioning.duration = self.durationForPresenting;
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.source =_presentingSource;
    return transitioning;
}

@end
