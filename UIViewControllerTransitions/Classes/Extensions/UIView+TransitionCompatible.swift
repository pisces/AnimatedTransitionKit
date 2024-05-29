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
//  UIView+Transitioning.swift
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2020/12/10.
//

import UIKit

extension UIView: TransitionCompatible { }

extension TransitionWrapper where Base: UIView {

    // MARK: Public

    public func findID() -> String? {
        findIDRecursively(in: base)
    }

    public func find(withID id: String?) -> UIView? {
        guard let id else { return nil }
        return findRecursively(withID: id, in: base)
    }

    // MARK: Private

    private func findIDRecursively(in view: UIView?) -> String? {
        guard let view else { return nil }
        if let id = view.transition.id { return id }

        var finded: String?
        view.subviews.forEach {
            if let id = findIDRecursively(in: $0) {
                finded = id
                return
            }
        }
        return finded
    }

    private func findRecursively(withID id: String?, in view: UIView?) -> UIView? {
        guard let id,
              let view else { return nil }
        guard view.transition.id != id else { return view }

        var finded: UIView?
        view.subviews.forEach {
            if let view = findRecursively(withID: id, in: $0) {
                finded = view
                return
            }
        }
        return finded
    }
}
