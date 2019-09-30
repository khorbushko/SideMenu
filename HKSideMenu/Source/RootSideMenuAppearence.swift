//
//  RootSideMenuAppearence.swift
//  HKSideMenu
//
//  Created by Kyryl Horbushko on 9/30/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

/**
 Represent different options for UI appearence customization related to `SideMenu`


 - Version: 0.1
 - Tag: 3000
 */
public class RootSideMenuAppearence {

  /// Side offset for menu - display visible gap when full menu isOpened
  ///
  /// Default - 60.0
  public static var openMenuOffset: CGFloat = 60

  /// Color which used for dimming content while side menu opened
  ///
  /// Default - UIColor.lightGray.withAlphaComponent(0.5)
  public static var dimmingViewColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)

  /// Indicate whenever we should used shadow on side menu while it's opened
  ///
  /// Default - true, enabled
  public static var showShadow: Bool = true

  /// Shadow color for side menu, used with `showShadow` option
  ///
  /// Default - UIColor.lightGray
  public static var shadowColor: UIColor = UIColor.lightGray

  /// Indicate whenever we should show side menu from left or right side
  ///
  /// Default - Show from right
  public static var showMenuOnRightSide: Bool = true

  /// Indicate whenever we should allow to perform damping pan for side menu when it comes to final position
  /// If enabled - make sure your side menu has some extended not clipped view
  ///
  /// Default - false, disabled
  public static var enablePanDamping: Bool = false

  /// Hold registered type for side menu
  public static var menuType: MenuPresentable.Type!
}
