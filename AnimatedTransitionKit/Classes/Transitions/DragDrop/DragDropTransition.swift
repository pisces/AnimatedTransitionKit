//
//  DragDropTransition.swift
//  Pods
//
//  Created by Minwoo on 9/3/25.
//

import UIKit

public final class DragDropTransition: AnimatedTransition {
    var imageViewContentMode: UIView.ContentMode = .scaleAspectFill
    public var dismissionSource: DragDropTransitioningSource?
    public var presentingSource: DragDropTransitioningSource?
    
    // MARK: - Overridden: AnimatedTransition
    
    override public func initProperties() {
        super.initProperties()
        appearenceOptions.animationOptions = UIView.AnimationOptions(rawValue: 7)
        disappearenceOptions.animationOptions = UIView.AnimationOptions(rawValue: 7)
        appearenceOptions.isUsingSpring = true
        disappearenceOptions.isUsingSpring = true
        imageViewContentMode = .scaleAspectFill
    }
    
    override public func transitioning(forDismissedController dismissed: UIViewController?) -> AnimatedTransitioning? {
        let transitioning = DragDropTransitioning()
        transitioning.imageViewContentMode = imageViewContentMode
        transitioning.source = dismissionSource
        return transitioning
    }
    
    override public func transitioningFor(forPresentedController presented: UIViewController?, presenting: UIViewController?, sourceController source: UIViewController?) -> AnimatedTransitioning? {
        let transitioning = DragDropTransitioning()
        transitioning.imageViewContentMode = imageViewContentMode
        transitioning.source = presentingSource
        return transitioning
    }
}
