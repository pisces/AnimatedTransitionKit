//
//  DragDropTransition.m
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 5/12/16.
//  Modified by Steve Kim on 4/14/17.
//      - Renew design and add new feature interactive transition
//      - Rename UIViewControllerDragDropTransition to DragDropTransition
//  Modified by Steve Kim on 8/14/17.
//      - Refactoring extract methods
//

#import "DragDropTransition.h"
#import "UIViewControllerTransitionsMacro.h"

@implementation DragDropTransition

#pragma mark - Overridden: UIViewControllerTransition

- (void)initProperties {
    [super initProperties];
    
    self.animationOptionsForDismission = self.animationOptionsForPresenting = 7;
    _imageViewContentMode = UIViewContentModeScaleAspectFill;
}

- (AnimatedTransitioning *)transitioningForDismissedController:(UIViewController *)dismissed {
    DragDropTransitioning *transitioning = [DragDropTransitioning new];
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.source = _dismissionSource;
    return transitioning;
}

- (AnimatedTransitioning *)transitioningForForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    DragDropTransitioning *transitioning = [DragDropTransitioning new];
    transitioning.imageViewContentMode = _imageViewContentMode;
    transitioning.source =_presentingSource;
    return transitioning;
}

@end
