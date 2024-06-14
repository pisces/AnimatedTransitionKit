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
//  FadeTransitionViewControllers.swift
//  AnimatedTransitionKitExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import AnimatedTransitionKit

final class FadeTransitionFirstViewController: UIViewController {
    
    private lazy var secondViewController: UINavigationController = {
        return UINavigationController(rootViewController: FadeTransitionSecondViewController(nibName: "FadeTransitionSecondView", bundle: .main))
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        
        secondViewController.transition = { [self] in
            $0.disappearenceInteractor?.direction = .vertical
            $0.appearenceInteractor?.direction = .vertical
            $0.appearenceInteractor?.attach(self, present: secondViewController)
            return $0
        }(FadeTransition())
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @IBAction func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

final class FadeTransitionSecondViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
