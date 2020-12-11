//  BSD 2-Clause License
//
//  Copyright (c) 2016 ~ 2020, Steve Kim
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
//  PinchInteractiveTransition.swift
//  UIViewControllerTransitions
//
//  Created by Steve Kim on 2020/12/10.
//

import Foundation

public final class PinchInteractiveTransition: AbstractInteractiveTransition {
    
    public override var gestureRecognizer: UIGestureRecognizer {
        pinchGestureRecognizer
    }
    
    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = { [unowned self] in
        .init(target: self, action: #selector(pinched))
    }()
}

extension PinchInteractiveTransition {
    @objc
    private func pinched(_ gestureRecognizer: UIPinchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            pinchBegan()
        case .changed where transition?.isInteracting == true:
            update(gestureRecognizer.scale)
        case .cancelled where transition?.isInteracting == true:
            cancel()
            transition?.endInteration()
        case .ended where transition?.isInteracting == true:
            switch isAppearing {
            case true where gestureRecognizer.scale >= 1.2,
                 false where gestureRecognizer.scale <= 0.8:
                finish()
            default:
                cancel()
            }
            transition?.endInteration()
        default:
            break
        }
    }
}

extension PinchInteractiveTransition {
    private var shouldBeginInteraction: Bool {
        (pinchGestureRecognizer.scale > 1 ? presentViewController : viewController) != nil
    }
    
    private func pinchBegan() {
        guard shouldBeginInteraction,
              transition?.isInteracting == false,
              (delegate?.interactor?(self, shouldInteractionWith: gestureRecognizer) ?? true) else { return }
        
        transition?.beginInteration()
        
        if !beginInteractiveTransition() {
            transition?.endInteration()
        }
    }
    
    private func beginInteractiveTransition() -> Bool {
        if pinchGestureRecognizer.scale > 1 {
            guard let presentViewController = presentViewController else { return false }
            viewController?.present(presentViewController, animated: true)
            return true
        }
        guard let viewController = viewController else { return false }
        viewController.dismiss(animated: true)
        return true
    }
}
