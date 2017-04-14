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
    
    private lazy var secondNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: self.secondViewController)
    }()
    
    private lazy var secondViewController: DragDropTransitionSecondViewController = {
        return DragDropTransitionSecondViewController(nibName: "DragDropTransitionSecondView", bundle: .main)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "First View"
        self.view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func tapped() {
        let transition = DragDropTransition()
        transition.isAllowsInteraction = true
        transition.sourceImage = imageView.image
        transition.interactionDelegate = secondViewController
        transition.interactionDataSource = secondViewController
        transition.dismissionInteractor?.attach(secondNavigationController, present: nil)
        
        let w = self.view.frame.size.width
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight = self.navigationController!.navigationBar.frame.size.height
        let bigRect = CGRect(x: 0, y: statusBarHeight + navigationBarHeight, width: w, height: w)
        let smallRect = imageView.frame
        
        transition.presentingSource = AnimatedDragDropTransitioningSource().from({
            return smallRect
        }, to: {
            return bigRect
        }, rotation: {
            return 0
        }, completion: {
            self.secondViewController.imageView.isHidden = false
            self.imageView.isHidden = true
        })
        
        transition.dismissionSource = AnimatedDragDropTransitioningSource().from({
            return bigRect
        }, to: {
            return smallRect
        }, rotation: {
            return 0
        }, completion: {
            self.imageView.isHidden = false
        })
        
        secondNavigationController.transition = transition
        
        self.navigationController?.present(secondNavigationController, animated: true, completion: nil)
    }
}

class DragDropTransitionSecondViewController: UIViewController, DragDropInteractiveTransitionDataSource, InteractiveTransitionDelegate {
    
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Second View"
        self.edgesForExtendedLayout = .bottom
        imageView.isHidden = true
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close)), animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageViewHeight.constant = self.view.frame.size.width
    }
    
    // MARK: - InteractiveTransition delegate
    
    func didBeginTransitioning() {
        imageView.isHidden = true
    }
    
    func didChangeTransitioning(_ percent: CGFloat) {
    }
    
    func didEndTransitioning() {
        imageView.isHidden = false
    }
    
    // MARK: - DragDropInteractiveTransition data source
    
    func sourceImageForInteraction() -> UIImage? {
        return imageView.image
    }
    
    func sourceImageRectForInteraction() -> CGRect {
        return imageView.frame
    }
    
    // MARK: - UIBarButtonItem selector
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
