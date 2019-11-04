//
//  TabBarController.swift
//  Example
//
//  Created by kyohei yamaguchi on 2019/11/03.
//  Copyright © 2019 kyo__hei. All rights reserved.
//

import UIKit
import ExtraTabBarController

class TabBarController: TabBarViewController {

    @IBOutlet var contents: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        extraView = contents
        
        let first = UIViewController(nibName: nil, bundle: nil)
        first.view.backgroundColor = .green
        first.tabBarItem = UITabBarItem(title: "First", image: UIImage(systemName: "sun.min"), tag: 1)
        
        
        
        let second = UIViewController(nibName: nil, bundle: nil)
        second.view.backgroundColor = .blue
        second.tabBarItem = UITabBarItem(title: "Second", image: UIImage(systemName: "square.and.pencil"), tag: 1)
        
        viewControllers = [first, second]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let v = UIView(frame: .zero)
        v.backgroundColor = UIColor.blue
        v.translatesAutoresizingMaskIntoConstraints = false
        viewControllers!.first!.view.addSubview(v)
        NSLayoutConstraint.activate([
            v.widthAnchor.constraint(equalToConstant: 100),
            v.heightAnchor.constraint(equalToConstant: 100),
            v.centerXAnchor.constraint(equalTo: viewControllers!.first!.view.centerXAnchor),
            v.bottomAnchor.constraint(equalTo: viewControllers!.first!.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}
