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
//  AnimatedNavigationTransition.swift
//  AnimatedTransitionKit
//
//  Created by Steve Kim on 5/29/25.
//

import Foundation
import Combine

open class AnimatedNavigationTransition: AbstractTransition {

    deinit {
        isEnabled = false
    }

    override public init() {
        super.init()
        setup()
        bind()
    }

    override open var isAllowsInteraction: Bool {
        didSet {
            interactor?.gestureRecognizer.isEnabled = isAllowsInteraction
        }
    }

    override open var currentInteractor: AbstractInteractiveTransition? {
        if self.isAllowsInteraction, self.isInteracting {
            return interactor
        }
        return nil
    }

    override open func isAppearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        guard interactor is PanningInteractiveTransition, isPush else {
            return false
        }
        let panningDirection = (interactor as? PanningInteractiveTransition)?.startPanningDirection
        return switch interactor.direction {
        case .vertical:
            panningDirection == .up
        case .horizontal:
            panningDirection == .left
        case .all:
            panningDirection == .left || panningDirection == .up
        @unknown default:
            false
        }
    }

    override open func isValid(_ interactor: AbstractInteractiveTransition) -> Bool {
        isPush ? isAppearing(interactor) : true
    }

    override open func shouldCompleteInteractor(_ interactor: AbstractInteractiveTransition) -> Bool {
        guard interactor is PanningInteractiveTransition else {
            return false
        }
        let panningDirection = (interactor as? PanningInteractiveTransition)?.panningDirection
        return switch interactor.direction {
        case .vertical:
            isPush
                ? panningDirection == .up
                : panningDirection == .down
        case .horizontal:
            isPush
                ? panningDirection == .left
                : panningDirection == .right
        case .all:
            isPush
                ? (panningDirection == .up || panningDirection == .left)
                : (panningDirection == .down || panningDirection == .right)
        @unknown default:
            false
        }
    }

    open func shouldUseTransitioning(
        for operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController)
    -> Bool
    {
        true
    }

    open func newTransitioning() -> AnimatedNavigationTransitioning? {
        nil
    }

    public var navigationController: UINavigationController? {
        get {
            return _navigationController
        }
        set {
            if newValue === _navigationController {
                return
            }
            if _navigationController == nil {
                originNCDelegate = if let navigationTransition = newValue?.delegate as? Self {
                    navigationTransition.originNCDelegate
                } else {
                    newValue?.delegate
                }
            }
            _navigationController = newValue
        }
    }
    private weak var _navigationController: UINavigationController?

    public var isEnabled: Bool = false {
        didSet {
            activateOrDeactivate()
        }
    }

    public var isPush: Bool {
        navigationTransitioning?.isPush ?? true
    }

    public var interactor: AbstractInteractiveTransition?

    public func destoryIfNeeded() {
        guard let targetViewController,
              let navigationController,
              navigationController.viewControllers.contains(targetViewController) == false else { return }
        targetViewController.cachedNavigationTransition = nil
    }

    weak var navigationTransition: AnimatedNavigationTransition?

    fileprivate weak var targetViewController: UIViewController?
    fileprivate var originNCDelegate: UINavigationControllerDelegate?

    private static let didShowViewControllerSubject = PassthroughSubject<UIViewController, Never>()

    private var navigationTransitioning: AnimatedNavigationTransitioning? {
        transitioning as? AnimatedNavigationTransitioning
    }

    private var cancellableSet: Set<AnyCancellable> = []

    private func shouldSendToOriginNCDelegate(_ selector: Selector) -> Bool {
        guard let originNCDelegate,
              (originNCDelegate is AnimatedNavigationTransition) == false else { return false }
        return originNCDelegate.responds(to: selector)
    }

    private func activateOrDeactivate() {
        guard let navigationController else { return }
        if isEnabled {
            navigationController.delegate = self
            interactor?.attach(navigationController)
        } else {
            interactor?.detach()
            navigationController.delegate = originNCDelegate;
        }
    }
}

extension AnimatedNavigationTransition {
    private func setup() {
        interactor = NavigationPanningInteractiveTransition()
        interactor?.direction = .horizontal
        interactor?.transition = self
        appearenceOptions.duration = UINavigationController.hideShowBarDuration
        disappearenceOptions.duration = UINavigationController.hideShowBarDuration
    }

    private func bind() {
        let didShowViewController = Self.didShowViewControllerSubject
            .removeDuplicates()

        let shouldAttachToInteractor: (UIViewController) -> Bool = { [weak self] in
            guard let self else { return false }
            return $0 === targetViewController || $0 === interactor?.viewControllerForAppearing
        }

        didShowViewController
            .filter { !shouldAttachToInteractor($0) }
            .sink { [weak self] _ in
                guard let self else { return }
                let cachedTransitions = navigationController?.viewControllers
                    .compactMap { $0.cachedNavigationTransition } ?? []
                if cachedTransitions.count < 1 {
                    self.navigationController?.navigationTransition = nil
                } else {
                    interactor?.detach()
                }
            }
            .store(in: &cancellableSet)

        didShowViewController
            .filter(shouldAttachToInteractor)
            .sink { [weak self] _ in
                guard let self,
                      let targetViewController,
                      let navigationController = targetViewController.navigationController else { return }

                if let cached = targetViewController.cachedNavigationTransition {
                    navigationController.navigationTransition = cached
                } else {
                    targetViewController.cachedNavigationTransition = self
                }
                interactor?.attach(navigationController)
            }
            .store(in: &cancellableSet)
    }
}

extension AnimatedNavigationTransition: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let shouldUseTransitioning = shouldUseTransitioning(for: operation, from: fromVC, to: toVC)
        if shouldUseTransitioning {
            if transitioning == nil {
                let transitioning = newTransitioning()
                transitioning?.appearenceOptions = appearenceOptions
                transitioning?.disappearenceOptions = disappearenceOptions
                self.transitioning = transitioning
            }
            let isPush = operation == .push
            navigationTransitioning?.isPush = isPush

            if isPush, toVC !== interactor?.viewControllerForAppearing {
                targetViewController = toVC
            }
            return transitioning
        } else {
            let selector = #selector(UINavigationControllerDelegate.navigationController(_:animationControllerFor:from:to:))
            if shouldSendToOriginNCDelegate(selector) {
                return originNCDelegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
            }
        }
        return nil
    }

    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if animationController === transitioning {
            return currentInteractor
        }
        let selector = #selector(UINavigationControllerDelegate.navigationController(_:interactionControllerFor:))
        if shouldSendToOriginNCDelegate(selector) {
            return originNCDelegate?.navigationController?(navigationController, interactionControllerFor: animationController)
        }
        return nil
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let selector = #selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:))
        if shouldSendToOriginNCDelegate(selector) {
            originNCDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        let selector = #selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))
        if shouldSendToOriginNCDelegate(selector) {
            originNCDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
        }
        Self.didShowViewControllerSubject.send(viewController)
    }

    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        let selector = #selector(UINavigationControllerDelegate.navigationControllerSupportedInterfaceOrientations(_:))
        if shouldSendToOriginNCDelegate(selector) {
            return originNCDelegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .portrait
        }
        return navigationController.topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        let selector = #selector(UINavigationControllerDelegate.navigationControllerPreferredInterfaceOrientationForPresentation(_:))
        if shouldSendToOriginNCDelegate(selector) {
            return originNCDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .unknown
        }
        return navigationController.topViewController?.preferredInterfaceOrientationForPresentation ?? .unknown
    }
}

extension UINavigationController {
    public var navigationTransition: AnimatedNavigationTransition? {
        get {
            objc_getAssociatedObject(self, &keyForNavigationTransition) as? AnimatedNavigationTransition
        }
        set {
            if newValue !== navigationTransition {
                navigationTransition?.isEnabled = false
                newValue?.navigationController = self
                objc_setAssociatedObject(self, &keyForNavigationTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            navigationTransition?.isEnabled = true
        }
    }
}

extension UIViewController {
    fileprivate var cachedNavigationTransition: AnimatedNavigationTransition? {
        get {
            objc_getAssociatedObject(self, &keyForCachedNavigationTransition) as? AnimatedNavigationTransition
        }
        set {
            objc_setAssociatedObject(self, &keyForCachedNavigationTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var keyForNavigationTransition: UInt8 = 0
private var keyForCachedNavigationTransition: UInt8 = 0
