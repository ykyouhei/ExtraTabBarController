//
//  TabBarViewController.swift
//  ExtraTabBarController
//
//  Created by kyohei yamaguchi on 2019/11/04.
//  Copyright © 2019 kyo__hei. All rights reserved.
//

import UIKit

open class TabBarViewController: UIViewController {
    
    private struct ExtraViewContainerConstraints {
        struct Compact {
            let left: NSLayoutConstraint
            let right: NSLayoutConstraint
            let bottom: NSLayoutConstraint
            let height: NSLayoutConstraint
            func active(_ active: Bool) {
                left.isActive = active
                right.isActive = active
                bottom.isActive = active
                height.isActive = active
            }
        }
        
        struct Regular {
            let top: NSLayoutConstraint
            let bottom: NSLayoutConstraint
            let right: NSLayoutConstraint
            let left: NSLayoutConstraint
            func active(_ active: Bool) {
                top.isActive = active
                bottom.isActive = active
                right.isActive = active
                left.isActive = active
            }
        }
        
        let compact: Compact
        let regular: Regular
    }
    
    /// 管理するViewControllerのリスト。最大5つまで。
    public var viewControllers: [UIViewController]? {
        didSet {
            tabBar.setItems(viewControllers!.map { $0.tabBarItem! }, animated: false)
            tabBar.selectedItem = viewControllers!.first!.tabBarItem
            showChildViewController(at: 0)
        }
    }
    
    /// 選択中のViewController
    unowned public private(set) var selectedViewController: UIViewController?
    
    /// 選択中のViewControllerのインデックス
    public private(set) var selectedIndex = -1

    /// 表示するTabBar
    public let tabBar = UITabBar(frame: .zero)
    
    /// `tabBar`の上部又は右に表示されるView
    public var extraView: UIView? {
        willSet {
            extraView?.removeFromSuperview()
        }
        didSet {
            guard let extraView = extraView else {
                return
            }
            
            extraView.translatesAutoresizingMaskIntoConstraints = false
            extraViewContainer.addSubview(extraView)
            
            NSLayoutConstraint.activate([
                extraView.topAnchor.constraint(equalTo: extraViewContainer.topAnchor),
                extraView.leftAnchor.constraint(equalTo: extraViewContainer.leftAnchor),
                extraView.rightAnchor.constraint(equalTo: extraViewContainer.rightAnchor),
                extraView.bottomAnchor.constraint(equalTo: extraViewContainer.bottomAnchor)
            ])
        }
    }
    
    /// childViewController用のコンテナ
    private let container = UIView(frame: .zero)
    
    /// horizontalSizeClass == .regular の場合に、`tabBar`の右側に表示されるダミー用のTabBar
    private let extraTabBar = UITabBar(frame: .zero)
    
    /// `extraView`のparentView
    private let extraViewContainer = UIView(frame: .zero)

    /// `extraViewContainer`のBlur用背景
    private let extraViewContainerBackground = UIVisualEffectView(effect: nil)

    /// `tabBar`と`extraTabBar`のセパレータ
    private let separator = UIView(frame: .zero)

    /// `extraViewContainer`の制約
    private var extraViewContainerConstraints: ExtraViewContainerConstraints!

    private var extraTabBarWidthConstraintForCompact: NSLayoutConstraint!
    private var extraTabBarWidthConstraintForRegular: NSLayoutConstraint!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBars()
        setupExtraViewContainer()
        setupContainer()
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateExtraViewContainerLayout()
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateExtraViewContainerLayout()
    }
    
    private func setupContainer() {
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(container)
        view.sendSubviewToBack(container)
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leftAnchor.constraint(equalTo: view.leftAnchor),
            container.rightAnchor.constraint(equalTo: view.rightAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTabBars() {
        extraTabBar.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        tabBar.delegate = self
        
        view.addSubview(extraTabBar)
        view.addSubview(tabBar)
        
        extraTabBarWidthConstraintForCompact = extraTabBar.widthAnchor.constraint(equalToConstant: 0)
        extraTabBarWidthConstraintForRegular = extraTabBar.widthAnchor.constraint(equalTo: tabBar.widthAnchor, multiplier: 0.4, constant: 0)
        
        NSLayoutConstraint.activate([
            tabBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            tabBar.rightAnchor.constraint(equalTo: extraTabBar.leftAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            extraTabBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            extraTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            extraTabBarWidthConstraintForCompact
        ])
    }
    
    private func setupExtraViewContainer() {
        extraViewContainer.backgroundColor = .clear
        extraViewContainer.clipsToBounds = false
        separator.backgroundColor = UIColor.systemGray2
        
        extraViewContainer.translatesAutoresizingMaskIntoConstraints = false
        extraViewContainerBackground.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        extraViewContainer.addSubview(extraViewContainerBackground)
        extraViewContainer.addSubview(separator)
        
        view.addSubview(extraViewContainer)
        view.bringSubviewToFront(extraViewContainer)
        
        extraViewContainerConstraints = ExtraViewContainerConstraints(
            compact: .init(
                left: extraViewContainer.leftAnchor.constraint(equalTo: tabBar.leftAnchor),
                right: extraViewContainer.rightAnchor.constraint(equalTo: tabBar.rightAnchor),
                bottom: extraViewContainer.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -0.5),
                height: extraViewContainer.heightAnchor.constraint(equalToConstant: 64)
            ),
            regular: .init(
                top: extraViewContainer.topAnchor.constraint(equalTo: extraTabBar.topAnchor),
                bottom: extraViewContainer.bottomAnchor.constraint(equalTo: extraTabBar.safeAreaLayoutGuide.bottomAnchor),
                right: extraViewContainer.rightAnchor.constraint(equalTo: extraTabBar.safeAreaLayoutGuide.rightAnchor),
                left: extraViewContainer.leftAnchor.constraint(equalTo: extraTabBar.leftAnchor)
            )
        )
        
        NSLayoutConstraint.activate([
            extraViewContainerBackground.topAnchor.constraint(equalTo: extraViewContainer.topAnchor),
            extraViewContainerBackground.leftAnchor.constraint(equalTo: extraViewContainer.leftAnchor),
            extraViewContainerBackground.rightAnchor.constraint(equalTo: extraViewContainer.rightAnchor),
            extraViewContainerBackground.bottomAnchor.constraint(equalTo: extraViewContainer.bottomAnchor),
            separator.topAnchor.constraint(equalTo: extraViewContainer.topAnchor, constant: 8),
            separator.leftAnchor.constraint(equalTo: extraViewContainer.leftAnchor, constant: -1),
            separator.widthAnchor.constraint(equalToConstant: 0.5),
            separator.bottomAnchor.constraint(equalTo: extraViewContainer.bottomAnchor, constant: -8)
        ])
    }
    
    private func updateExtraViewContainerLayout() {
        view.bringSubviewToFront(extraViewContainer)
        
        if traitCollection.horizontalSizeClass == .compact {
            extraTabBarWidthConstraintForRegular.isActive = false
            extraViewContainerConstraints.regular.active(false)
            
            extraTabBarWidthConstraintForCompact.isActive = true
            extraViewContainerConstraints.compact.active(true)
            extraViewContainerBackground.effect = UIBlurEffect(style: .systemChromeMaterial)
        } else {
            extraTabBarWidthConstraintForCompact.isActive = false
            extraViewContainerConstraints.compact.active(false)
            
            extraTabBarWidthConstraintForRegular.isActive = true
            extraViewContainerConstraints.regular.active(true)
            extraViewContainerBackground.effect = nil
        }
        
        view.needsUpdateConstraints()
        view.layoutIfNeeded()
        
        updateChildSafeArea()
    }

    private func updateChildSafeArea() {
        var newSafeArea = UIEdgeInsets()
        newSafeArea.bottom = view.bounds.height - extraViewContainer.frame.minY - view.safeAreaInsets.bottom
        viewControllers?.forEach {
            $0.additionalSafeAreaInsets = newSafeArea
        }
    }

}

extension TabBarViewController: UITabBarDelegate {
    
    public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = viewControllers!.firstIndex { $0.tabBarItem == item }!
        showChildViewController(at: index)
    }
    
    private func showChildViewController(at index: Int) {
        if let selectedViewController = selectedViewController {
            selectedViewController.willMove(toParent: nil)
            selectedViewController.view.removeFromSuperview()
            selectedViewController.removeFromParent()
        }
        
        let nextVC = viewControllers![index]
        nextVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(nextVC)
        
        container.addSubview(nextVC.view)
        NSLayoutConstraint.activate([
            nextVC.view.topAnchor.constraint(equalTo: container.topAnchor),
            nextVC.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            nextVC.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            nextVC.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        nextVC.didMove(toParent: self)
        
        selectedViewController = nextVC
        selectedIndex = index
    }
    
}
