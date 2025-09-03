//
//  FadeTransition.swift
//  Pods
//
//  Created by Minwoo on 9/3/25.
//

import UIKit

public final class FadeTransition: AnimatedTransition {
    // MARK: - Overridden: AnimatedTransition
    
    override public func transitioning(forDismissedController dismissed: UIViewController?) -> AnimatedTransitioning? {
        FadeTransitioning()
    }
    
    override public func transitioningFor(forPresentedController presented: UIViewController?, presenting: UIViewController?, sourceController source: UIViewController?) -> AnimatedTransitioning? {
        FadeTransitioning()
    }
}
