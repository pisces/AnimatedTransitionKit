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
    
    private lazy var secondViewController: GesturePresentingSecondViewController = {
        let controller = GesturePresentingSecondViewController(nibName: "GesturePresentingSecondView", bundle: .main)
        controller.modalPresentationStyle = .custom
        controller.transition = UIViewControllerMoveTransition()
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        let presentingInteractor = PanningInteractiveTransition()
        presentingInteractor.attach(self, present: secondViewController)
        
        secondViewController.transition?.presentingInteractor = presentingInteractor
    }
}
