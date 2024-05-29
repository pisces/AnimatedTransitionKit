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
//  TransitionCompatible.swift
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2020/12/10.
//

import Foundation

public protocol TransitionCompatible: AnyObject {
  associatedtype CompatibleType

  var transition: TransitionWrapper<CompatibleType> { get }
}

extension TransitionCompatible {
    public var transition: TransitionWrapper<Self> {
        guard let value = objc_getAssociatedObject(self, &keyForTransition) as? TransitionWrapper<Self> else {
            let value = TransitionWrapper(self)
            objc_setAssociatedObject(self, &keyForTransition, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return value
    }
}

public final class TransitionWrapper<Base> {
    public init(_ base: Base) {
        self.base = base
    }

    public let base: Base

    public var id: String? {
        get {
            objc_getAssociatedObject(base, &keyForTransitionID) as? String
        }
        set {
            objc_setAssociatedObject(base, &keyForTransitionID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func clear() {
        id = nil
    }
}

private var keyForTransition: UInt8 = 0
private var keyForTransitionID: UInt8 = 0
