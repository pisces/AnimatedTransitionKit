//
//  GesturePresentingSecondViewController.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 11/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIKit

@objc class GesturePresentingSecondViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Gesture Presenting Second View"
            
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(aaa)), animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(rawValue: 0), animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    @objc private func aaa() {
        self.dismiss(animated: true, completion: nil)
    }
}
