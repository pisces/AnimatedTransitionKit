//
//  DemoViewController.swift
//  UIViewControllerTransitionsExample
//
//  Created by pisces on 14/04/2017.
//  Copyright © 2017 Steve Kim. All rights reserved.
//

import UIViewControllerTransitions

@objc class DemoViewController: UITableViewController {
    
    private let titles: [String] = [
        "DragDropTransition",
        "MoveTransition",
        "FadeTransition"
    ]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
            cell!.accessoryType = .disclosureIndicator
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.text = titles[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var controller: UIViewController?
        
        switch indexPath.row {
        case 0:
            controller = DragDropTransitionFirstViewController(nibName: "DragDropTransitionFirstView", bundle: .main)
        case 1:
            controller = MoveTransitionFirstViewController(nibName: "MoveTransitionFirstView", bundle: .main)
        case 2:
            controller = FadeTransitionFirstViewController(nibName: "FadeTransitionFirstView", bundle: .main)
            break
        default:
            break
        }
        
        if let controller = controller {
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}
