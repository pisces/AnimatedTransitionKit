//
//  NavigationMoveTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 13/08/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

class NavigationMoveTransitionFirstViewController: UIViewController {
    
    private lazy var secondViewController: NavigationMoveTransitionSecondViewController = {
        return NavigationMoveTransitionSecondViewController(nibName: "NavigationMoveTransitionSecondView", bundle: .main)
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close", style: .plain, target: self, action: #selector(close))
        navigationController?.navigationTransition = NavigationMoveTransition()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear -> \(type(of: self))")
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear -> \(type(of: self))")
        
        if let navigationController = navigationController {
            navigationController.navigationTransition?.interactor.attach(navigationController, present: secondViewController)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear -> \(type(of: self))")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear -> \(type(of: self))")
    }
    
    @IBAction func clicked() {
        navigationController?.pushViewController(secondViewController, animated: true)
    }
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}

class NavigationMoveTransitionSecondViewController: UITableViewController, InteractiveTransitionDelegate {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear -> \(type(of: self))")
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.navigationTransition?.interactor.delegate = self
        print("viewDidAppear -> \(type(of: self))")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear -> \(type(of: self))")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear -> \(type(of: self))")
    }
    
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
    
    func didBegin(withInteractor interactor: AbstractInteractiveTransition) {
        tableView.panGestureRecognizer.isEnabled = false
    }
    func didChange(withInteractor interactor: AbstractInteractiveTransition, percent: CGFloat) {
    }
    func didCancel(withInteractor interactor: AbstractInteractiveTransition) {
        tableView.panGestureRecognizer.isEnabled = true
    }
    func didComplete(withInteractor interactor: AbstractInteractiveTransition) {
        tableView.panGestureRecognizer.isEnabled = true
    }
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteractionWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
