//
//  MoveTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

class MoveTransitionFirstViewController: UIViewController, InteractiveTransitionDelegate {
    
    private var interactor: AbstractInteractiveTransition? {
        return secondViewController.transition?.presentingInteractor
    }
    private lazy var secondViewController: MoveTransitionSecondViewController = {
        let viewController = MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main)
        let transition = MoveTransition()
        transition.durationForPresenting = 0.25
        transition.durationForDismission = 0.35
        transition.dismissionInteractor?.delegate = viewController
        transition.presentingInteractor?.delegate = self
        transition.isAllowsInteraction = true
        viewController.interactionDelegate = self
        viewController.transition = transition
        return viewController
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
        interactor?.attach(self, present: secondViewController)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear")
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear")
    }
    
    @IBAction func clicked() {
        present(secondViewController, animated: true, completion: nil)
    }
}

class MoveTransitionSecondViewController: UIViewController, InteractiveTransitionDelegate {
    
    weak var interactionDelegate: InteractiveTransitionDelegate?
    
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
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("viewWillAppear MoveTransitionSecondViewController")
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("viewDidAppear MoveTransitionSecondViewController")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("viewWillDisappear MoveTransitionSecondViewController")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        print("viewDidDisappear MoveTransitionSecondViewController")
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
