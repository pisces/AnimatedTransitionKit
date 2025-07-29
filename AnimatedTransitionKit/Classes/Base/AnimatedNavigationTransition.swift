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

import Combine
import Foundation

// MARK: - AnimatedNavigationTransition

open class AnimatedNavigationTransition: AbstractTransition {

    // MARK: Lifecycle

    deinit {
        isEnabled = false
    }

    override public init() {
        super.init()
        setup()
        bind()
    }

    // MARK: Open

    override open var isAllowsInteraction: Bool {
        didSet {
            interactor?.gestureRecognizer.isEnabled = isAllowsInteraction
        }
    }
    override open var currentInteractor: AbstractInteractiveTransition? {
        if isAllowsInteraction, isInteracting {
            return interactor
        }
        return nil
    }

    override open func interactionCancelled(_ interactor: AbstractInteractiveTransition, completion: (() -> Void)? = nil) {
        super.interactionCancelled(interactor) { [weak self] in
            if let self, let latestOperationInfo, latestOperationInfo.operation == .push {
                pushedViewControllerWrappers.removeAll { $0.value === latestOperationInfo.toVC }
            }
            completion?()
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

    // MARK: Public

    public var interactor: AbstractInteractiveTransition?

    public var navigationController: UINavigationController? {
        get {
            _navigationController
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
                previousViewController = newValue?.visibleViewController
            }
            _navigationController = newValue
        }
    }
    public var isEnabled: Bool = false {
        didSet {
            activateOrDeactivate()
        }
    }
    public var isPush: Bool {
        navigationTransitioning?.isPush ?? true
    }

    override public func setViewControllerForAppearing(_ viewController: UIViewController) {
        interactor?.viewControllerForAppearing = viewController
    }

    // MARK: Internal

    var lastPushedViewController: UIViewController? {
        pushedViewControllerWrappers.last?.value as? UIViewController
    }

    // MARK: Fileprivate

    fileprivate var originNCDelegate: UINavigationControllerDelegate?

    // MARK: Private

    private static let didShowViewControllerSubject = PassthroughSubject<UIViewController, Never>()

    private weak var _navigationController: UINavigationController?
    private weak var previousViewController: UIViewController?

    private var pushedViewControllerWrappers: [WeakWrapper] = []
    private var cancellableSet: Set<AnyCancellable> = []
    private var latestOperationInfo: NavigationOperationInfo?

    private var navigationTransitioning: AnimatedNavigationTransitioning? {
        transitioning as? AnimatedNavigationTransitioning
    }

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
            .filter { [weak self] _ in self?.lastPushedViewController != nil }

        let shouldAttachToInteractor: (UIViewController) -> Bool = { [weak self] vc in
            guard let self else { return false }
            let isContains = pushedViewControllerWrappers.contains { $0.value === vc }
            return isContains || hasInteractorDataSource(vc)
        }

        didShowViewController
            .filter { !shouldAttachToInteractor($0) }
            .sink { [weak self] _ in
                guard let self, let navigationController else { return }
                if navigationController.hasCacheNavigationTransition {
                    interactor?.detach()
                } else {
                    navigationController.navigationTransition = nil
                }
            }
            .store(in: &cancellableSet)

        didShowViewController
            .filter(shouldAttachToInteractor)
            .sink { [weak self] _ in
                guard let self,
                      let lastPushedViewController,
                      let navigationController = lastPushedViewController.navigationController else { return }
                if let cached = navigationController.cachedNavigationTransition(for: lastPushedViewController) {
                    navigationController.navigationTransition = cached
                } else {
                    navigationController.setCachedNavigationTransition(self, for: lastPushedViewController)
                }
                interactor?.attach(navigationController)
            }
            .store(in: &cancellableSet)
    }
}

extension AnimatedNavigationTransition {

    // MARK: Public

    override public func isValid(_ interactor: AbstractInteractiveTransition) -> Bool {
        if isAppearing(interactor) {
            isValidForAppearing(interactor)
        } else if isDisappearing(interactor) {
            isValidForDisappearing(interactor)
        } else {
            false
        }
    }

    // MARK: Private

    private func isValidForAppearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        guard let navigationController else { return false }
        let hasInteractorDataSource = hasInteractorDataSource(navigationController.visibleViewController)
        let isPushed = interactor.viewControllerForAppearing.map {
            navigationController.viewControllers.contains($0)
        } ?? false
        return hasInteractorDataSource && !isPushed
    }

    private func hasInteractorDataSource(_ viewController: UIViewController?) -> Bool {
        guard let viewController else { return false }
        if viewController === interactor?.dataSource { return true }
        for child in viewController.children {
            if hasInteractorDataSource(child) {
                return true
            }
        }
        return false
    }

    private func isValidForDisappearing(_ interactor: AbstractInteractiveTransition) -> Bool {
        guard let navigationController else { return false }
        return navigationController.visibleViewController === interactor.viewControllerForAppearing ||
            navigationController.visibleViewController === lastPushedViewController
    }
}

// MARK: UINavigationControllerDelegate

extension AnimatedNavigationTransition: UINavigationControllerDelegate {

    // MARK: Public

    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        latestOperationInfo = .init(operation: operation, fromVC: fromVC, toVC: toVC)

        let shouldUseTransitioning = shouldUseTransitioning(for: operation, from: fromVC, to: toVC)
        if shouldUseTransitioning {
            if transitioning == nil, let transitioning = newTransitioning() {
                transitioning.appearenceOptions = appearenceOptions
                transitioning.disappearenceOptions = disappearenceOptions
                transitioning.storeInteractor(interactor)
                self.transitioning = transitioning
            }
            navigationTransitioning?.isPush = operation == .push
            appendPushedVC(toVC, for: operation)
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
        handlePopGestureException(navigationController, fromVC: previousViewController, toVC: viewController)

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
        removePushedVC(viewController)
        previousViewController = viewController
        latestOperationInfo = nil
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

    // MARK: Private

    private func handlePopGestureException(
        _ navigationController: UINavigationController,
        fromVC: UIViewController?,
        toVC: UIViewController)
    {
        guard latestOperationInfo == nil, let fromVC else { return }

        let operation = operation(with: navigationController, fromVC: fromVC)

        latestOperationInfo = .init(operation: operation, fromVC: fromVC, toVC: toVC)

        let shouldUseTransitioning = shouldUseTransitioning(for: operation, from: fromVC, to: toVC)
        if shouldUseTransitioning {
            appendPushedVC(toVC, for: operation)
        }
    }

    private func operation(
        with navigationController: UINavigationController,
        fromVC: UIViewController?)
        -> UINavigationController.Operation
    {
        if let fromVC, !navigationController.viewControllers.contains(fromVC) {
            .pop
        } else {
            .push
        }
    }

    private func appendPushedVC(
        _ viewController: UIViewController,
        for operation: UINavigationController.Operation)
    {
        guard operation == .push else { return }
        let wrapper = WeakWrapper(value: viewController)
        pushedViewControllerWrappers.append(wrapper)
    }

    private func removePushedVC(_ viewController: UIViewController) {
        guard let latestOperationInfo,
              latestOperationInfo.operation == .pop,
              latestOperationInfo.toVC === viewController else { return }
        pushedViewControllerWrappers.removeAll {
            $0.value === latestOperationInfo.fromVC
        }
    }
}

// MARK: - NavigationOperationInfo

private final class NavigationOperationInfo {

    // MARK: Lifecycle

    init(operation: UINavigationController.Operation, fromVC: UIViewController? = nil, toVC: UIViewController? = nil) {
        self.operation = operation
        self.fromVC = fromVC
        self.toVC = toVC
    }

    // MARK: Internal

    let operation: UINavigationController.Operation
    weak var fromVC: UIViewController?
    weak var toVC: UIViewController?
}

extension UINavigationController {

    // MARK: Public

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

    // MARK: Fileprivate

    fileprivate var hasCacheNavigationTransition: Bool {
        cachedNavigationTransitionDict.count > 0
    }

    fileprivate func cachedNavigationTransition(for viewController: UIViewController) -> AnimatedNavigationTransition? {
        cachedNavigationTransitionDict[viewController.hashValue]
    }

    fileprivate func setCachedNavigationTransition(_ transition: AnimatedNavigationTransition?, for viewController: UIViewController) {
        cachedNavigationTransitionDict[viewController.hashValue] = transition
    }

    // MARK: Private

    private typealias DictType = [Int: AnimatedNavigationTransition]

    private var cachedNavigationTransitionDict: DictType {
        get {
            guard let value = objc_getAssociatedObject(self, &keyForCachedNavigationTransitionDict) as? DictType else {
                let value: DictType = [:]
                objc_setAssociatedObject(self, &keyForCachedNavigationTransitionDict, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return value
            }
            return value
        }
        set {
            objc_setAssociatedObject(self, &keyForCachedNavigationTransitionDict, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private var keyForNavigationTransition: UInt8 = 0
private var keyForCachedNavigationTransitionDict: UInt8 = 0
