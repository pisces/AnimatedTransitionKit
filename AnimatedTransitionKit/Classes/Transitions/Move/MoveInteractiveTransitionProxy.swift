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
//  MoveInteractiveTransitionProxy.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 7/15/25.
//

import Foundation

struct MoveInteractiveTransitionProxy {

    let direction: MoveTransitioningDirection

    func isAppearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        let startPanningDirection = (interactor as? PanningInteractiveTransition)?.startPanningDirection
        return switch (direction, startPanningDirection) {
        case (.up, .up),
             (.down, .down),
             (.left, .left),
             (.right, .right):
            true
        default:
            false
        }
    }

    func isDisappearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        let startPanningDirection = (interactor as? PanningInteractiveTransition)?.startPanningDirection
        return switch (direction, startPanningDirection) {
        case (.up, .down),
             (.down, .up),
             (.left, .right),
             (.right, .left):
            true
        default:
            false
        }
    }

    func shouldCompleteInteractor(_ interactor: AbstractInteractiveTransition, transition: AbstractTransition) -> Bool {
        let isAppearing = switch transition {
        case let navigationTransition as AnimatedNavigationTransition:
            navigationTransition.isPush
        case let modalTransition as AnimatedTransition:
            modalTransition.isPresenting
        default:
            false
        }
        let panningDirection = (interactor as? PanningInteractiveTransition)?.panningDirection
        return switch direction {
        case .up:
            isAppearing
                ? panningDirection == .up
                : panningDirection == .down
        case .down:
            isAppearing
                ? panningDirection == .down
                : panningDirection == .up
        case .left:
            isAppearing
                ? panningDirection == .left
                : panningDirection == .right
        case .right:
            isAppearing
                ? panningDirection == .right
                : panningDirection == .left
        }
    }
}
