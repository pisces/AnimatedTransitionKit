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
//  ZoomTransitionViewControllers.swift
//  UIViewControllerTransitions_Example
//
//  Created by Steve Kim on 2020/12/10.
//  Copyright © 2020 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

final class ZoomTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"

        // View binding with any transition id
        button.transition.id = "zoomTarget"
        
        secondViewController.transition = { [self] in
            $0.isAllowsInteraction = true
            $0.appearenceInteractor?.attach(self, present: secondViewController)
            return $0
        }(ZoomTransition())
    }

    // MARK: - Private
    
    private lazy var secondViewController: UINavigationController = {
        let rootViewController = UIStoryboard(name: "ZoomTransition", bundle: nil).instantiateViewController(withIdentifier: "SecondScene")
        return UINavigationController(rootViewController: rootViewController)
    }()
    
    @IBOutlet private weak var button: UIButton!
    
    @IBAction private func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

final class ZoomTransitionSecondViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        
        // View binding with matched transition id
        targetView.transition.id = "zoomTarget"
    }
    
    // MARK: - Internal
    
    @IBOutlet private(set) weak var targetView: UIView!
    
    // MARK: - Private
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
