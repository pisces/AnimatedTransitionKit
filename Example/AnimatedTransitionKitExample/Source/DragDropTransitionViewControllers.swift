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
//  DragDropTransitionViewControllers.swift
//  AnimatedTransitionKitExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import AnimatedTransitionKit

final class DragDropTransitionFirstViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        view.addGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Private
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        UITapGestureRecognizer(target: self, action: #selector(tapped))
    }()
    
    @objc private func tapped() {
        let secondViewController = DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)

        secondNavigationController.transition = { [self] in
            $0.disappearenceInteractor?.delegate = secondViewController

            let w = view.frame.size.width
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            let navigationBarHeight = navigationController!.navigationBar.frame.size.height
            let bigRect = CGRect(x: 0, y: statusBarHeight + navigationBarHeight, width: w, height: w)
            let smallRect = imageView.frame

            $0.presentingSource = .image(
                { imageView.image },
                from: { smallRect },
                to: { bigRect },
                rotation: { 0 },
                completion: {
                    imageView.isHidden = true
                    secondViewController.imageView.isHidden = false
                })
            $0.dismissionSource = .image(
                { secondViewController.imageView.image },
                from: { bigRect },
                to: { smallRect },
                rotation: { 0 },
                completion: { imageView.isHidden = false })
            return $0
        }(DragDropTransition())

        navigationController?.present(secondNavigationController, animated: true, completion: nil)
    }
}

class DragDropTransitionSecondViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        edgesForExtendedLayout = .bottom
        imageView.isHidden = true
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageViewHeight.constant = view.frame.size.width
    }
    
    // MARK: - Internal

    @IBOutlet private(set) weak var imageView: UIImageView!
    
    // MARK: - Private

    @IBOutlet private weak var imageViewHeight: NSLayoutConstraint!
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - InteractiveTransitionDelegate

extension DragDropTransitionSecondViewController: InteractiveTransitionDelegate {

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
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteract gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
