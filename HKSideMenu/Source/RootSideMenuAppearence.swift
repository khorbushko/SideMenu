//
//  RootSideMenuAppearence.swift
//  HKSideMenu
//
//  Created by Kyryl Horbushko on 9/30/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

public class RootSideMenuAppearence {

  public static var openMenuOffset: CGFloat = 60
  public static var dimmingViewColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)

  public static var showShadow: Bool = true
  public static var shadowColor: UIColor = UIColor.lightGray

  public static var showMenuOnRightSide: Bool = false
  public static var enablePanDamping: Bool = false

  public static var menuType: MenuPresentable.Type!
}
