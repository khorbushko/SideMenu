//
//  MenuController.swift
//  HKSideMenu
//
//  Created by Kirill Gorbushko on 5/28/19.
//  Copyright © 2019 - present. All rights reserved.
//

import UIKit

/**
 Represent Simple class that holds base logic for SideMenu displaying

 - Version: 0.1
 - Tag: 5000
 */
open class RootSideMenuController: UIViewController {

  enum Constants {

    enum Animation {

      static let showDimmedView = "showDimmedView"
      static let hideDimmedView = "hideDimmedView"

      enum KeyPath {

        static let position = "position"
        static let opacity = "opacity"
      }

      enum Duration {

        static let `default`: TimeInterval = 0.3
      }
    }
  }

  /// callbacks that will be called whenever side menu is opened or closed
  public var didOpenMenu, didCloseMenu: (() -> ())?

  /// momentary state of side menu
  public private (set) var state: RootSideMenuState = .closed

  private var dimmedView: UIView = UIView()
  private var shadowLayer: CALayer = CALayer()

  private var startLocation: CGPoint = CGPoint.zero
  private var movingProgress:CGFloat = 0
  private weak var menuController: MenuPresentable?
  private weak var menuView: UIView?

  // MARK: - LifeCycle

  override open func viewDidLoad() {
    super.viewDidLoad()

    addMenuController()
  }

  override open func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()

    menuController?.viewWillLayoutSubviews()
    drawShadowIfNeeded()
  }

  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    prepareDimmedView()
  }

  // MARK: - Public

  /// Call this function to hide menu
  @objc public func hideMenu() {
    moveMenuToState(.closed)
  }

  /// Call this function to show menu
  @objc public func showMenu() {
    moveMenuToState(.open)
  }

  // MARK: - Actions

  @objc private func panMenuAction(_ gesture: UIPanGestureRecognizer) {

    guard let menuView = menuView else {
      assert(self.menuView != nil, "menuView is nil")
      return
    }

    switch gesture.state {
    case .began:
      startLocation = gesture.location(in: view)
    case .changed:
      let currentLocation: CGPoint = gesture.location(in: view)
      let movedDistance = currentLocation.x - startLocation.x
      startLocation = currentLocation

      let newPosition = CGPoint(x: menuView.center.x + movedDistance, y: menuView.center.y)

      let menuOffset: CGFloat = menuView.frame.width / 2
      var minXPoint = menuOffset + RootSideMenuAppearence.openMenuOffset
      var maxXpoint = menuOffset + view.frame.width - RootSideMenuAppearence.openMenuOffset / 2

      if !RootSideMenuAppearence.showMenuOnRightSide {
        minXPoint = -menuView.frame.width / 2
        maxXpoint = menuView.frame.width / 2
      }

      let canPerformManualMoving = newPosition.x > minXPoint && newPosition.x < maxXpoint

      if canPerformManualMoving {
        menuView.center = newPosition
      } else {
        if RootSideMenuAppearence.enablePanDamping {
          let dampingKoef: CGFloat = 0.8
          let dampedNewPosition = CGPoint(x: menuView.center.x + movedDistance * dampingKoef, y: menuView.center.y)
          menuView.center = dampedNewPosition
        } else {
          return
        }
      }

      // progress
      let fullDistance = menuView.frame.width
      var currentDistance = menuView.center.x - menuView.frame.width / 2 - RootSideMenuAppearence.openMenuOffset
      if !RootSideMenuAppearence.showMenuOnRightSide {
        currentDistance = menuView.frame.maxX
      }

      var movingProgress: CGFloat = currentDistance / fullDistance
      if !RootSideMenuAppearence.showMenuOnRightSide {
        movingProgress = 1 - movingProgress
      }

      self.movingProgress = movingProgress

      dimmedView.layer.opacity = Float(1 - movingProgress)

    case .ended,
         .cancelled:

      let menuStateChangeTriggerThresold: CGFloat = 100
      let currentViewOriginX = menuView.frame.origin.x

      var requireOpenAnimation = currentViewOriginX < (RootSideMenuAppearence.openMenuOffset + menuStateChangeTriggerThresold)
      if !RootSideMenuAppearence.showMenuOnRightSide {
        let currentViewMaxX = menuView.frame.maxX
        requireOpenAnimation = currentViewMaxX > (RootSideMenuAppearence.openMenuOffset + menuStateChangeTriggerThresold)
      }

      if requireOpenAnimation {
        openMenuAction()
      } else {
        closeMenuAction()
      }
    default:
      break
    }
  }

  // MARK: - Private

  private func addMenuController() {
    assert(RootSideMenuAppearence.menuType != nil, "menu type is not configured, Check `RootSideMenuAppearence.menuType`")
    let bundle = Bundle(for: RootSideMenuAppearence.menuType)
    if let menuController = UIStoryboard(name: RootSideMenuAppearence.menuType.storyboardName, bundle: bundle)
      .instantiateViewController(withIdentifier: RootSideMenuAppearence.menuType.controllerIdentifier) as? MenuPresentable {

      menuController.willMove(toParent: self)
      self.addChild(menuController)
      self.view.addSubview(menuController.view)
      if RootSideMenuAppearence.showMenuOnRightSide {
        menuController.view.frame = CGRect(x: view.frame.width,
                                           y: 0,
                                           width: view.frame.width - RootSideMenuAppearence.openMenuOffset,
                                           height: view.frame.height)
      } else {
        menuController.view.frame = CGRect(x: -view.frame.width,
                                           y: 0,
                                           width: view.frame.width - RootSideMenuAppearence.openMenuOffset,
                                           height: view.frame.height)
      }

      menuController.didMove(toParent: self)

      self.menuController = menuController
      self.menuView = menuController.view
    } else {
      assertionFailure("MenuController can't be created for side menu component")
    }
  }

  private func prepareDimmedView() {
    dimmedView.removeFromSuperview()

    if let menuView = menuController?.view {
      dimmedView = UIView()
      dimmedView.backgroundColor = RootSideMenuAppearence.dimmingViewColor

      view.insertSubview(dimmedView, belowSubview: menuView)
      dimmedView.layer.zPosition = 0
      dimmedView.isHidden = true
      dimmedView.translatesAutoresizingMaskIntoConstraints = false
      addConstraintsForView(dimmedView, withTopOffset: 0)

      let dimmedPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(RootSideMenuController.panMenuAction(_:)))
      dimmedPanGesture.delaysTouchesBegan = false
      dimmedView.addGestureRecognizer(dimmedPanGesture)

      let dimmedTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RootSideMenuController.hideMenu))
      dimmedView.addGestureRecognizer(dimmedTapGesture)
    }
  }

  private func addConstraintsForView(_ nView: UIView, withTopOffset topOffset: CGFloat) {

    view.addConstraints([NSLayoutConstraint(item: nView,
                                            attribute: .bottom,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .bottom,
                                            multiplier: 1.0,
                                            constant: 0),

                         NSLayoutConstraint(item: nView,
                                            attribute: .top,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .top,
                                            multiplier: 1.0,
                                            constant: topOffset),

                         NSLayoutConstraint(item: nView,
                                            attribute: .left,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .left,
                                            multiplier: 1.0,
                                            constant: 0),

                         NSLayoutConstraint(item: nView,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: view,
                                            attribute: .right,
                                            multiplier: 1.0,
                                            constant: 0)
      ])
  }

  // MARK: - Calculation

  private func calculateFinalOpenMenuPosition() -> CGPoint {
    if RootSideMenuAppearence.showMenuOnRightSide {
      let toPoint: CGPoint = CGPoint(x: view.center.x + RootSideMenuAppearence.openMenuOffset / 2, y: view.center.y)
      return toPoint
    } else {
      let toPoint: CGPoint = CGPoint(x: view.center.x - RootSideMenuAppearence.openMenuOffset / 2, y: view.center.y)
      return toPoint
    }
  }

  private func calculateFinalHiddenMenuPosition() -> CGPoint {
    if RootSideMenuAppearence.showMenuOnRightSide {
      var toPoint: CGPoint = CGPoint(x: view.frame.width, y: view.center.y)
      if let menuView = menuView {
        toPoint.x += menuView.bounds.width / 2
      }
      return toPoint
    } else {
      var toPoint: CGPoint = CGPoint(x: -view.frame.width, y: view.center.y)
      if let menuView = menuView {
        toPoint.x = -menuView.bounds.width / 2
      }
      return toPoint
    }
  }

  private func moveMenuToState(_ newState: RootSideMenuState) {
    if newState == state {
      return
    }

    if state == .open {
      closeMenuAction()
    } else {
      openMenuAction()
    }
  }

  private func closeMenuAction() {
    if let moveAnimation = closeMenuAnimation() {
      menuController?.view.layer.add(moveAnimation, forKey:nil)
      menuController?.view.layer.position = calculateFinalHiddenMenuPosition()

      let fadeOutAnimation = fadeAnimFromValue(fromValue: CGFloat(1 - movingProgress), toValue: 0, delegate: self)
      dimmedView.layer.add(fadeOutAnimation, forKey: Constants.Animation.hideDimmedView)
      dimmedView.layer.opacity = 0
      movingProgress = 0
    }
  }

  private func openMenuAction() {
    if let moveAnimation = openMenuAnimation() {
      menuController?.view.layer.add(moveAnimation, forKey:nil)
      menuController?.view.layer.position = calculateFinalOpenMenuPosition()

      if dimmedView.isHidden {
        dimmedView.isHidden = false
        dimmedView.layer.opacity = 1

        let fadeInAnimation = fadeAnimFromValue(fromValue: CGFloat(1 - movingProgress), toValue: 1, delegate: self)
        dimmedView.layer.add(fadeInAnimation, forKey: Constants.Animation.showDimmedView)
      }
      movingProgress = 1
    }
  }

  // MARK: - Shadow

  private func drawShadowIfNeeded() {
    shadowLayer.removeFromSuperlayer()

    if RootSideMenuAppearence.showShadow,
      let menuView = menuController?.view {
      menuView.layer.shadowOffset = CGSize(width: -2, height: 0)
      menuView.layer.shadowColor = RootSideMenuAppearence.shadowColor.cgColor
      menuView.layer.shadowRadius = 0.5
      menuView.layer.shadowOpacity = 0.3
      menuView.layer.masksToBounds = false
      menuView.layer.shouldRasterize = true
      menuView.layer.rasterizationScale = UIScreen.main.scale
    }
  }

  // MARK: Animation

  private func openMenuAnimation() -> CABasicAnimation? {
    if let menuView = menuController?.view {

      let finalPosition: CGPoint = calculateFinalOpenMenuPosition()
      let startPosition: CGPoint = menuView.center
      let moveAnimation: CASpringAnimation = CASpringAnimation(keyPath: Constants.Animation.KeyPath.position)
      moveAnimation.duration = Constants.Animation.Duration.default * 2

      moveAnimation.fromValue = NSValue(cgPoint: startPosition)
      moveAnimation.toValue = NSValue(cgPoint: finalPosition)
      moveAnimation.initialVelocity = -3.0
      moveAnimation.mass = 0.25
      return moveAnimation
    }

    return nil
  }

  private func closeMenuAnimation() -> CAKeyframeAnimation? {
    if let menuView = menuController?.view {
      let moveAnimation: CAKeyframeAnimation = CAKeyframeAnimation(keyPath: Constants.Animation.KeyPath.position)

      let finalPosition: CGPoint = calculateFinalHiddenMenuPosition()
      let startPosition: CGPoint = menuView.center

      moveAnimation.values = [
        startPosition,
        finalPosition
      ]
      moveAnimation.duration = Constants.Animation.Duration.default
      moveAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
      return moveAnimation
    }

    return nil
  }

  private func fadeAnimFromValue(fromValue: CGFloat,
                                 toValue: CGFloat,
                                 delegate: CAAnimationDelegate?) -> CABasicAnimation {
    let fadeAnimation: CABasicAnimation = CABasicAnimation(keyPath: Constants.Animation.KeyPath.opacity)
    fadeAnimation.fromValue = fromValue
    fadeAnimation.toValue = toValue
    fadeAnimation.duration = Constants.Animation.Duration.default
    fadeAnimation.isRemovedOnCompletion = delegate == nil
    fadeAnimation.delegate = delegate
    fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

    return fadeAnimation
  }
}

extension RootSideMenuController: CAAnimationDelegate {

  // MARK : CAAnimationDelegate

  open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if (anim == dimmedView.layer.animation(forKey: Constants.Animation.hideDimmedView)) {
      dimmedView.layer.removeAllAnimations()
      dimmedView.isHidden = true
      state = .closed

      didCloseMenu?()
    } else if (anim == dimmedView.layer.animation(forKey: Constants.Animation.showDimmedView)) {
      dimmedView.layer.removeAllAnimations()
      state = .open

      didOpenMenu?()
    }
  }
}
