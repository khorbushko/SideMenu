//
//  MenuPresentable.swift
//  HKSideMenu
//
//  Created by Kyryl Horbushko on 9/30/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

public protocol MenuPresentable where Self: UIViewController {

  static var controllerIdentifier: String { get }

  static var storyboardName: String { get }
}

public extension MenuPresentable {

  static var controllerIdentifier: String {
    return String(describing: self)
  }
}
