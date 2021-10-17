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
//  MoveTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

final class MoveTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First View"
        secondViewController.transition?.appearenceInteractor?.attach(self, present: secondViewController)
    }
    
    // MARK: - Private
    
    private lazy var secondViewController: UINavigationController = {
        let viewController = MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main)
        let transition = MoveTransition()
        transition.appearenceOptions.duration = 0.25
        transition.disappearenceOptions.duration = 0.35
        transition.isAllowsInteraction = true
        transition.disappearenceInteractor?.delegate = viewController
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.transition = transition
        return navigationController
    }()
    
    @IBAction private func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

final class MoveTransitionSecondViewController: UITableViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
        (navigationController?.transition as? MoveTransition)?.relatedScrollView = tableView
    }
    
    // MARK: - Overridden: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = "\(indexPath.row + 1)"
    }
    
    // MARK: - Private
    
    private var isInteractionBegan = false
    private var isViewAppeared = false
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - InteractiveTransitionDelegate

extension MoveTransitionSecondViewController: InteractiveTransitionDelegate {
    
    func shouldTransition(_ interactor: AbstractInteractiveTransition) -> Bool {
        navigationController?.viewControllers.count == 1
    }
    
    func didCancel(withInteractor interactor: AbstractInteractiveTransition) {
        print("didCancel")
    }
    
    func didComplete(withInteractor interactor: AbstractInteractiveTransition) {
        print("didComplete")
    }
}
