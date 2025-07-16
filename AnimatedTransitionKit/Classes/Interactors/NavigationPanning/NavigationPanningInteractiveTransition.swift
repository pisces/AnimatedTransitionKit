//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~, Steve Kim
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  NavigationPanningInteractiveTransition.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 5/29/25.
//

import Foundation

open class NavigationPanningInteractiveTransition: PanningInteractiveTransition {

    // MARK: Public

    override public var isInteractionEnabled: Bool {
        guard let transition,
              let navigationController else { return false }
        return if transition.isAppearing(self) {
            viewControllerForAppearing.map { !navigationController.viewControllers.contains($0) } ?? false
        } else {
            navigationController.viewControllers.count > 1
        }
    }

    override public func beginInteractiveTransition() -> Bool {
        guard let transition,
              let navigationController else { return false }
        if transition.isAppearing(self) {
            guard let viewControllerForAppearing else { return false }
            let shouldPush = !navigationController.viewControllers.contains(viewControllerForAppearing)
            if shouldPush {
                navigationController.pushViewController(viewControllerForAppearing, animated: true)
            }
        } else {
            navigationController.popViewController(animated: true)
        }
        return true
    }

    // MARK: Private

    private var navigationController: UINavigationController? {
        viewController as? UINavigationController
    }
}
