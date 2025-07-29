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
//  UINavigationController+.swift
//  AnimatedTransitionKit
//
//  Created by pisces on 7/29/25.
//

import Combine

extension UINavigationController {

    // MARK: Public

    public var navigationTransition: AnimatedNavigationTransition? {
        get {
            objc_getAssociatedObject(self, &keyForNavigationTransition) as? AnimatedNavigationTransition
        }
        set {
            if newValue !== navigationTransition {
                if navigationTransition == nil, newValue != nil {
                    previousViewController = visibleViewController
                    bind()
                }
                navigationTransition?.isEnabled = false
                newValue?.navigationController = self
                objc_setAssociatedObject(self, &keyForNavigationTransition, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            navigationTransition?.isEnabled = true
        }
    }

    // MARK: Internal

    var lastestTransitionVC: UIViewController? {
        transitionVCWrappers.last?.value as? UIViewController
    }
    var latestOperationInfo: NavigationOperationInfo? {
        get {
            objc_getAssociatedObject(self, &keyForLatestOperationInfo) as? NavigationOperationInfo
        }
        set {
            objc_setAssociatedObject(self, &keyForLatestOperationInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func sendDidShowViewController(_ viewController: UIViewController, transition: AnimatedNavigationTransition) {
        didShowViewControllerSubject.send((viewController, transition))
        removeTransitionVC(viewController)
        previousViewController = viewController
        latestOperationInfo = nil
    }

    func handlePopGestureException(
        _ navigationTransition: AnimatedNavigationTransition,
        toVC: UIViewController)
    {
        guard latestOperationInfo == nil, let fromVC = previousViewController else { return }

        let operation = operation(fromVC: fromVC)

        latestOperationInfo = .init(operation: operation, fromVC: fromVC, toVC: toVC)

        let shouldUseTransitioning = navigationTransition.shouldUseTransitioning(for: operation, from: fromVC, to: toVC)
        if shouldUseTransitioning {
            appendTransitionVC(toVC, for: operation)
        }
    }

    func appendTransitionVC(
        _ viewController: UIViewController,
        for operation: UINavigationController.Operation)
    {
        guard operation == .push else { return }
        let wrapper = WeakWrapper(value: viewController)
        transitionVCWrappers.append(wrapper)
    }

    func cancelTransition() {
        guard let latestOperationInfo, latestOperationInfo.operation == .push else { return }
        transitionVCWrappers.removeAll { $0.value === latestOperationInfo.toVC }
    }

    // MARK: Private

    private typealias DictType = [Int: AnimatedNavigationTransition]

    private var hasCacheNavigationTransition: Bool {
        cachedNavigationTransitionDict.count > 0
    }

    private var cachedNavigationTransitionDict: DictType {
        get {
            lazyGet(target: self, forKey: &keyForCachedNavigationTransitionDict) { [:] }
        }
        set {
            objc_setAssociatedObject(self, &keyForCachedNavigationTransitionDict, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var didShowViewControllerSubject: PassthroughSubject<(UIViewController, AnimatedNavigationTransition), Never> {
        lazyGet(target: self, forKey: &keyForDidShowViewControllerSubject) {
            .init()
        }
    }
    private var transitionVCWrappers: [WeakWrapper] {
        get {
            lazyGet(target: self, forKey: &keyForTransitionVCWrappers) { [] }
        }
        set {
            objc_setAssociatedObject(self, &keyForTransitionVCWrappers, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var cancellableSet: Set<AnyCancellable> {
        get {
            if let set = objc_getAssociatedObject(self, &keyForCancellableSet) as? NSMutableSet,
               let typedSet = set as? Set<AnyCancellable>
            {
                return typedSet
            } else {
                let newSet = Set<AnyCancellable>()
                objc_setAssociatedObject(self, &keyForCancellableSet, newSet, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return newSet
            }
        }
        set {
            objc_setAssociatedObject(self, &keyForCancellableSet, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private var previousViewController: UIViewController? {
        get {
            objc_getAssociatedObject(self, &keyForPreviousViewController) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &keyForPreviousViewController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    private func bind() {
        didShowViewControllerSubject
            .sink { [weak self] viewController, navigationTransition in
                guard let self else { return }
                let isContains = transitionVCWrappers.contains { $0.value === viewController }
                let shouldAttachToInteractor = isContains || navigationTransition.hasInteractorDataSource(viewController)
                if shouldAttachToInteractor {
                    if let cached = cachedNavigationTransition(for: viewController) {
                        self.navigationTransition = cached
                        removeCachedNavigationTransition(for: viewController)
                    } else {
                        setCachedNavigationTransition(navigationTransition, for: viewController)
                    }
                    self.navigationTransition?.interactor?.attach(self)
                } else {
                    removeCachedNavigationTransitionsIfNotContains()

                    if hasCacheNavigationTransition {
                        self.navigationTransition?.interactor?.detach()
                    } else {
                        self.navigationTransition = nil
                    }
                }
            }
            .store(in: &cancellableSet)
    }

    private func cachedNavigationTransition(for viewController: UIViewController) -> AnimatedNavigationTransition? {
        cachedNavigationTransitionDict[viewController.hashValue]
    }

    private func setCachedNavigationTransition(_ transition: AnimatedNavigationTransition?, for viewController: UIViewController) {
        if let transition {
            cachedNavigationTransitionDict[viewController.hashValue] = transition
        }
    }

    private func removeCachedNavigationTransition(for viewController: UIViewController) {
        cachedNavigationTransitionDict.removeValue(forKey: viewController.hashValue)
    }

    private func removeCachedNavigationTransitionsIfNotContains() {
        cachedNavigationTransitionDict.keys
            .filter { key in !viewControllers.contains(where: { $0.hashValue == key }) }
            .forEach { key in cachedNavigationTransitionDict.removeValue(forKey: key) }
    }

    private func operation(fromVC: UIViewController?) -> UINavigationController.Operation {
        if let fromVC, !viewControllers.contains(fromVC) {
            .pop
        } else {
            .push
        }
    }

    private func removeTransitionVC(_ viewController: UIViewController) {
        guard let latestOperationInfo,
              latestOperationInfo.operation == .pop,
              latestOperationInfo.toVC === viewController else { return }
        transitionVCWrappers.removeAll {
            $0.value === latestOperationInfo.fromVC
        }
    }
}

private var keyForNavigationTransition: UInt8 = 0
private var keyForCachedNavigationTransitionDict: UInt8 = 0
private var keyForDidShowViewControllerSubject: UInt8 = 0
private var keyForTransitionVCWrappers: UInt8 = 0
private var keyForCancellableSet: UInt8 = 0
private var keyForPreviousViewController: UInt8 = 0
private var keyForLatestOperationInfo: UInt8 = 0

private func lazyGet<T>(target: Any, forKey key: UnsafeRawPointer, creation: () -> T) -> T {
    guard let value = objc_getAssociatedObject(target, key) as? T else {
        let value = creation()
        objc_setAssociatedObject(target, key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return value
    }
    return value
}

// MARK: - NavigationOperationInfo

final class NavigationOperationInfo {

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
