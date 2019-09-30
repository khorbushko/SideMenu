//
//  MenuPresentable.swift
//  HKSideMenu
//
//  Created by Kyryl Horbushko on 9/30/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

/**
 Implement this protol for `UIViewController` to mark your controller as one that you would like to use as side menu

 ### Note:

 To make it visible for [RootSideMenuController](x-source-tag://5000)
 please configure your [RootSideMenuAppearence](x-source-tag://3000) `menuType` with Type of your class

        RootSideMenuAppearence.menuType = MyMenu.self //before RootSideMenuController `viewDidLoad`

 - Version: 0.1
 - Tag: 1000
 */
public protocol MenuPresentable where Self: UIViewController {

  /// Name for storyboard file in which Menu controller xib placed
  ///
  /// Version: - 0.0.1
  static var storyboardName: String { get }

  /// Storyboard ID of menu controller
  ///
  ///Default implementation - `String(describing: self)`
  ///
  /// Version: - 0.0.1
  static var controllerIdentifier: String { get }
}

public extension MenuPresentable {

  static var controllerIdentifier: String {
    return String(describing: self)
  }
}
