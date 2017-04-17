//
//  MoveTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

class MoveTransitionFirstViewController: UIViewController {
    
    private lazy var secondViewController: UINavigationController = {
        return UINavigationController(rootViewController: MoveTransitionSecondViewController(nibName: "MoveTransitionSecondView", bundle: .main))
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "First View"
        
        let transition = MoveTransition()
        transition.isAllowsInteraction = true
        transition.presentingInteractor?.attach(self, present: secondViewController)
        
        secondViewController.transition = transition
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
        self.present(secondViewController, animated: true, completion: nil)
    }
}

class MoveTransitionSecondViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Second View"
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
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
        self.dismiss(animated: true, completion: nil)
    }
}
