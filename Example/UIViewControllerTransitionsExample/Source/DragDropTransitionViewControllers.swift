//
//  DragDropTransitionViewControllers.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

class DragDropTransitionFirstViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private lazy var gestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(tapped))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "First View"
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func tapped() {
        let secondViewController = DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
        let secondNavigationController = UINavigationController(rootViewController: secondViewController)
        
        let transition = DragDropTransition()
        transition.isAllowsInteraction = true
        transition.dismissionInteractor?.delegate = secondViewController
        
        let w = view.frame.size.width
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = navigationController!.navigationBar.frame.size.height
        let bigRect = CGRect(x: 0, y: statusBarHeight + navigationBarHeight, width: w, height: w)
        let smallRect = imageView.frame
        
        transition.presentingSource = DragDropTransitioningSource.image({ () -> UIImage? in
            return self.imageView.image
        }, from: { () -> CGRect in
            return smallRect
        }, to: { () -> CGRect in
            return bigRect
        }, rotation: { () -> CGFloat in
            return 0
        }) {
            self.imageView.isHidden = true
            secondViewController.imageView.isHidden = false
        }
        
        transition.dismissionSource = DragDropTransitioningSource.image({ () -> UIImage? in
            return secondViewController.imageView.image
        }, from: { () -> CGRect in
            return bigRect
        }, to: { () -> CGRect in
            return smallRect
        }, rotation: { () -> CGFloat in
            return 0
        }) {
            self.imageView.isHidden = false
        }
        
        secondNavigationController.transition = transition
        
        navigationController?.present(secondNavigationController, animated: true, completion: nil)
    }
}

class DragDropTransitionSecondViewController: UIViewController, InteractiveTransitionDelegate {
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Second View"
        edgesForExtendedLayout = .bottom
        imageView.isHidden = true
        
        navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageViewHeight.constant = view.frame.size.width
    }
    
    // MARK: - InteractiveTransition delegate
    
    func didBegin(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = true
    }
    func didChange(withInteractor interactor: AbstractInteractiveTransition, percent: CGFloat) {
    }
    func didCancel(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func didComplete(withInteractor interactor: AbstractInteractiveTransition) {
        imageView.isHidden = false
    }
    func interactor(_ interactor: AbstractInteractiveTransition, gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch?) -> Bool {
        return true
    }
    func interactor(_ interactor: AbstractInteractiveTransition, shouldInteractionWith gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - UIBarButtonItem selector
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
}
