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

@synthesize interactionDataSource = _interactionDataSource;

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
    
    if ([_interactionDataSource respondsToSelector:@selector(sourceImageForInteraction)]) {
        transitioning.sourceImage = [_interactionDataSource sourceImageForInteraction];
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
