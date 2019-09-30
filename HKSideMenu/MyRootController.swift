//
//  MyRootController.swift
//  HKSideMenu
//
//  Created by Kyryl Horbushko on 9/30/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

final class MyRootController: RootSideMenuController {

  // MARK: - LifeCycle

  override func viewDidLoad() {
    RootSideMenuAppearence.menuType = MenuController.self
    RootSideMenuAppearence.dimmingViewColor = UIColor.cyan.withAlphaComponent(0.8)

    super.viewDidLoad()
  }

  // MARK: - Action

  @IBAction private func myButtonAction() {
    switch state {
      case .open:
        hideMenu(true)
      case .closed:
        showMenu(true)
    }
  }
}
