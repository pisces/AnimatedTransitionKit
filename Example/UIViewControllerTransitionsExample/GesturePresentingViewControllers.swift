//
//  GesturePresentingFirstViewController.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

@objc class GesturePresentingFirstViewController: UIViewController {
    
    private lazy var secondViewController: UINavigationController = {
        return UINavigationController(rootViewController: GesturePresentingSecondViewController(nibName: "GesturePresentingSecondView", bundle: .main))
    }()
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        let transition = MoveTransition()
        transition.isAllowsInteraction = true
        transition.dismissionInteractor?.attach(secondViewController, present: nil)
        transition.presentingInteractor?.attach(self, present: secondViewController)
        
        secondViewController.transition = transition
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @IBAction func clicked() {
        self.present(secondViewController, animated: true, completion: nil)
    }
}
