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
//  ZoomTransitionViewControllers.swift
//  AnimatedTransitionKit_Example
//
//  Created by Steve Kim on 2020/12/10.
//  Copyright © 2020 Steve Kim. All rights reserved.
//

import AnimatedTransitionKit

final class ZoomTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"

        // View binding with any transition id
        button.transitionItem.id = "zoomTarget"
        
        zoomTransition.prepareAppearance(from: self)
    }

    // MARK: - Private

    private lazy var zoomTransition = {
        $0.isAllowsInteraction = true
        $0.appearenceInteractor?.dataSource = self
        return $0
    }(ZoomTransition())

    @IBOutlet private weak var button: UIButton!
    
    @IBAction private func clicked() {
        present(createSecondVC(), animated: true, completion: nil)
    }
}

extension ZoomTransitionFirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }

    private func createSecondVC() -> UIViewController {
        let rootVC = UIStoryboard(name: "ZoomTransition", bundle: nil).instantiateViewController(withIdentifier: "SecondScene")
        let navigationController = UINavigationController(rootViewController: rootVC)
        navigationController.transition = zoomTransition
        return navigationController
    }
}

final class ZoomTransitionSecondViewController: UIViewController {
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        
        // View binding with matched transition id
        targetView.transitionItem.id = "zoomTarget"
    }
    
    // MARK: - Internal
    
    @IBOutlet private(set) weak var targetView: UIView!
    
    // MARK: - Private
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
