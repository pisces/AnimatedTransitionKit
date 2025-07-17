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
//  NavigationMoveTransitionViewControllers.swift
//  AnimatedTransitionKitExample
//
//  Created by pisces on 13/08/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import AnimatedTransitionKit

final class NavigationMoveTransitionFirstViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "First View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close))
        navigationController?.navigationTransition = {
            $0.interactor?.dataSource = self
            return $0
        }(NavigationMoveTransition())
    }
    
    // MARK: - Private
    
    @IBAction private func clicked() {
        let vc = createSecondVC()
        navigationController?.navigationTransition?.setViewControllerForAppearing(vc)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension NavigationMoveTransitionFirstViewController: InteractiveTransitionDataSource {
    func viewController(forAppearing interactor: AbstractInteractiveTransition) -> UIViewController? {
        createSecondVC()
    }

    private func createSecondVC() -> UIViewController {
        NavigationMoveTransitionSecondViewController()
    }
}

final class NavigationMoveTransitionSecondViewController: UITableViewController {
    
    // MARK: - Lifecycle

    init() {
        super.init(nibName: "NavigationMoveTransitionSecondView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Second View"
    }
    
    // MARK: - Overridden: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = NavigationMoveTransitionSecondViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
