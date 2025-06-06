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
//  TransitionItemCompatible.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 2020/12/10.
//

import Foundation

// MARK: - TransitionItemCompatible

public protocol TransitionItemCompatible: AnyObject {
    associatedtype CompatibleType: AnyObject

    var transitionItem: TransitionItemWrapper<CompatibleType> { get }
}

extension TransitionItemCompatible {
    public var transitionItem: TransitionItemWrapper<Self> {
        guard let value = objc_getAssociatedObject(self, &keyForTransitionItem) as? TransitionItemWrapper<Self> else {
            let value = TransitionItemWrapper(self)
            objc_setAssociatedObject(self, &keyForTransitionItem, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
        return value
    }
}

// MARK: - TransitionItemWrapper

public final class TransitionItemWrapper<Base> where Base: AnyObject {

    // MARK: Lifecycle

    public init(_ base: Base) {
        self.base = base
    }

    // MARK: Public

    public var id: String? {
        get {
            guard let base else { return nil }
            return objc_getAssociatedObject(base, &keyForTransitionID) as? String
        }
        set {
            if let transitionView = transitionView(with: newValue) {
                transitionView.transitionItem.clear()
            }
            if let base {
                objc_setAssociatedObject(base, &keyForTransitionID, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }

    public func clear() {
        id = nil
    }

    // MARK: Internal

    private(set) weak var base: Base?

    // MARK: Private

    private func transitionView(with id: String?) -> UIView? {
        guard let id,
              let responder = base as? UIResponder,
              let rootView = viewController(for: responder)?.view else
        {
            return nil
        }
        return rootView.transitionItem.find(withID: id)
    }

    private func viewController(for responder: UIResponder) -> UIViewController? {
        if let vc = responder as? UIViewController,
           vc.parent == nil || vc.parent === vc.navigationController
        {
            return vc
        }
        if let nextResponser = responder.next {
            return viewController(for: nextResponser)
        }
        return nil
    }
}

private var keyForTransitionItem: UInt8 = 0
private var keyForTransitionID: UInt8 = 0
