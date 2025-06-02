//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2021, Steve Kim
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
//  ZoomTransition.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 2020/12/10.
//

import UIKit

public final class ZoomTransition: AnimatedTransition {

    override public func initProperties() {
        super.initProperties()
        appearenceInteractor = PinchInteractiveTransition()
        disappearenceInteractor = PinchInteractiveTransition()
        appearenceOptions.isUsingSpring = true
        appearenceOptions.animationOptions = .init(rawValue: 7)
        disappearenceOptions.isUsingSpring = true
        disappearenceOptions.animationOptions = .init(rawValue: 7)
    }

    override public func transitioning(forDismissedController dismissed: UIViewController?) -> AnimatedTransitioning? {
        ZoomTransitioning()
    }

    override public func transitioningFor(forPresentedController presented: UIViewController?, presenting: UIViewController?, sourceController source: UIViewController?) -> AnimatedTransitioning? {
        ZoomTransitioning()
    }
}
