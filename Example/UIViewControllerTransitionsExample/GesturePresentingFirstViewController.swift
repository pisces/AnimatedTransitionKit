//
//  GesturePresentingFirstViewController.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIKit
import UIViewControllerTransitions

@objc class GesturePresentingFirstViewController: UIViewController {
    
    private var secondNavigationController: UINavigationController!
    
    private lazy var secondViewController: GesturePresentingSecondViewController = {
        let controller = GesturePresentingSecondViewController(nibName: "GesturePresentingSecondView", bundle: .main)
        return controller
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        let transition = UIViewControllerMoveTransition()
        transition.isAllowsInteraction = true
//        transition.dismissionInteractor?.direction = .horizontal
//        transition.presentingInteractor?.direction = .horizontal
        
        secondNavigationController = UINavigationController(rootViewController: secondViewController)
        secondNavigationController.modalPresentationStyle = .custom
        secondNavigationController.transition = transition
        
        transition.dismissionInteractor?.attach(secondNavigationController, present: nil)
        transition.presentingInteractor?.attach(self, present: secondNavigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @IBAction func clicked() {
        self.present(secondNavigationController, animated: true, completion: nil)
    }
}
