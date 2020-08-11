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
//  DragDropTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

final class DragDropTransitionFirstViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(tapped))
    }()
    private lazy var secondViewController: UINavigationController = {
        let viewController = DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
        let navigationController = UINavigationController(rootViewController: viewController)
        let yOffset = UIApplication.shared.statusBarFrame.size.height + navigationController.navigationBar.frame.size.height
        
        let transition = DragDropTransition()
        transition.isAllowsInteraction = true
        
        transition.presentingSource = .image(
            { [weak imageView] in imageView?.image },
            from: { [weak imageView] in imageView?.frame ?? .zero },
            to: { [unowned self] in .init(x: 0, y: yOffset, width: self.view.bounds.width, height: self.view.bounds.width) },
            rotation: { 0 },
            completion: {
                self.imageView.isHidden = true
                viewController.imageView.isHidden = false
            })
        
        transition.dismissionSource = .image(
            { [weak viewController] in viewController?.imageView.image },
            from: { [unowned self] in .init(x: 0, y: yOffset, width: self.view.bounds.width, height: self.view.bounds.width) },
            to: { [weak imageView] in imageView?.frame ?? .zero },
            rotation: { 0 },
            completion: {
                self.imageView.isHidden = false
            })
        
        navigationController.transition = transition
        
        return navigationController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func tapped() {
        navigationController?.present(secondViewController, animated: true, completion: nil)
    }
}

final class DragDropTransitionSecondViewController: UIViewController, InteractiveTransitionDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        edgesForExtendedLayout = .bottom
        imageView.isHidden = true
        navigationController?.transition?.dismissionInteractor?.delegate = self
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    
    // MARK: - InteractiveTransition delegate
    
    func didBegin(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = true
    }
    func didChange(withInteractor interactor: AbstractInteractiveTransition, percent: CGFloat) {
    }
    func didCancel(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func didComplete(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func interactor(_ interactor: AbstractInteractiveTransition, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch?) -> Bool {
        return true
    }
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteractionWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIBarButtonItem selector
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
