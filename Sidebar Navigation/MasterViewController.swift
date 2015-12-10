//
//  ViewController.swift
//  Sidebar Navigation
//

import UIKit

class MasterViewController: UIViewController, MainMenuDelegate {

	var selectedIndex: Int? = 0
	
	private var maxWidthForMenu: CGFloat! {
		if traitCollection.horizontalSizeClass == .Regular {
			if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
				return UIApplication.sharedApplication().keyWindow!.bounds.size.width / 3.5
			} else {
				return UIApplication.sharedApplication().keyWindow!.bounds.size.width / 2.5
			}
		} else {
			if UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) {
				return UIApplication.sharedApplication().keyWindow!.bounds.size.width * 0.45
			} else {
				return UIApplication.sharedApplication().keyWindow!.bounds.size.width * 0.75
			}
		}
	}
	
	private let maxAlpha: CGFloat = 0.3
	private var backgroundView: UIView?
	private var menuviewController: MenuViewController?
	private var leadingMenuConstraint: NSLayoutConstraint?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		let menuButton = UIButton(frame: CGRectZero)
		menuButton.setTitle("Menu", forState: .Normal)
		menuButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
		menuButton.addTarget(self, action: "showMenuFromButton:", forControlEvents: .TouchUpInside)
		view.addSubview(menuButton)
		menuButton.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraint(NSLayoutConstraint(item: menuButton, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 16))
		view.addConstraint(NSLayoutConstraint(item: menuButton, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 16))
	}
	
	func showMenuFromButton(sender: UIButton) {
		addMainMenuToChildViewControllers()
		if let menuView = menuviewController?.parentView {
			menuView.translatesAutoresizingMaskIntoConstraints = false
			leadingMenuConstraint = NSLayoutConstraint(item: menuView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: -maxWidthForMenu)
			view.addConstraint(leadingMenuConstraint!)
			view.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
			view.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
			menuView.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: maxWidthForMenu))
			menuView.layoutIfNeeded()
			
			menuviewController?.drawShadow()
			leadingMenuConstraint?.constant = 0
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				menuView.layoutIfNeeded()
				self.backgroundView?.alpha = self.maxAlpha
			})
		}
	}
	
//	func performTapAction(sender: UITapGestureRecognizer) {
//		switch (sender.state) {
//		case .Began:
//			break
//		case .Changed:
//			break
//		case .Ended:
//			break
//		default:
//			break
//		}
//	}
	
	func closeMenu(complete: (() -> Void)?) {
//		let tapGesture = UITapGestureRecognizer(target: self, action: Selector("performTapAction:"))
//		view.addGestureRecognizer(tapGesture)
		
		if let menuView = menuviewController?.parentView {
			for constraint in menuView.constraintsAffectingLayoutForAxis(.Horizontal) {
				if let firstItem = constraint.firstItem as? UIView,
					let secondItem = constraint.secondItem as? UIView {
						if firstItem == menuView && constraint.firstAttribute == .Leading && secondItem == view && constraint.secondAttribute == .Leading {
							constraint.constant = -maxWidthForMenu
							break
						}
				}
			}
			
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				menuView.layoutIfNeeded()
				}, completion: { (completed) -> Void in
					menuView.removeFromSuperview()
					self.menuviewController?.removeFromParentViewController()
					self.menuviewController = nil
					self.backgroundView?.removeFromSuperview()
					self.backgroundView = nil
					complete?()
			})
		}
	}
	
	func didSelectCell(cell: MenuCell) {
		closeMenu { () -> Void in
			print("Cell was selected: \(cell)")
			
			
		}
	}
	
	func addMainMenuToChildViewControllers() {
		
		backgroundView = UIView(frame: CGRectZero)
		backgroundView!.backgroundColor = UIColor.blackColor()
		backgroundView!.alpha = 0.0
		view.addSubview(backgroundView!)
		backgroundView!.translatesAutoresizingMaskIntoConstraints = false
		
		view.addConstraint(NSLayoutConstraint(item: backgroundView!, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: backgroundView!, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: backgroundView!, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: backgroundView!, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
		
		
		if menuviewController == nil {
			menuviewController = MenuViewController()
			menuviewController?.delegate = self
			let navigationVC = UINavigationController(rootViewController: menuviewController!)
			self.addChildViewController(navigationVC)
			view.addSubview(navigationVC.view)
			navigationVC.didMoveToParentViewController(self)
			
		}
	}
	
	
	private var startingTouch: CGPoint?
	private var deltaX: CGFloat = 0
	private var startTimeStamp: NSTimeInterval!
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if let touchPoint = touches.first?.locationInView(view)
		 	where touchPoint.x > maxWidthForMenu && menuviewController != nil {
				startingTouch = touchPoint
		} else if let touchPoint = touches.first?.locationInView(view)
			where touchPoint.x < 30 && menuviewController == nil {
				startingTouch = touchPoint
		}
		
		guard let touchEvent = event else {
			return
		}
		startTimeStamp = touchEvent.timestamp
	}
	
	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let currentPoint = touches.first?.locationInView(view)
			where startingTouch != nil else {
				return
		}
		
		guard let menuView = menuviewController?.parentView else {
			if startingTouch!.x + 10 < currentPoint.x {
				addMainMenuToChildViewControllers()
				deltaX = currentPoint.x - startingTouch!.x
				if let menuView = menuviewController?.parentView {
					menuView.translatesAutoresizingMaskIntoConstraints = false
					leadingMenuConstraint = NSLayoutConstraint(item: menuView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: -maxWidthForMenu)
					view.addConstraint(leadingMenuConstraint!)
					view.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
					view.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
					menuView.addConstraint(NSLayoutConstraint(item: menuView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: maxWidthForMenu))
					menuView.layoutIfNeeded()
					menuviewController?.drawShadow()
				}
			}
			return
		}
		
		let percentageOpen = (menuView.frame.size.width + menuView.frame.origin.x) / (maxWidthForMenu / 100) / 100
		backgroundView?.alpha = maxAlpha * percentageOpen
		
		if currentPoint.x <= maxWidthForMenu + deltaX {
			leadingMenuConstraint?.constant = -(maxWidthForMenu - currentPoint.x + deltaX)
		} else {
			leadingMenuConstraint?.constant = 0
		}
		view.updateConstraintsIfNeeded()
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard let touchPoint = touches.first?.locationInView(view)
			where startingTouch != nil else {
				return
		}
		
		if menuviewController != nil {
			var dismiss = false
			if let endTouchEvent = event
			 where endTouchEvent.timestamp < startTimeStamp + 0.2 {
				leadingMenuConstraint?.constant = -maxWidthForMenu
				dismiss = true
			} else  {
				switch touchPoint.x {
				case startingTouch!.x:
					leadingMenuConstraint?.constant = -maxWidthForMenu
					dismiss = true
				case CGFloat(0.0)..<(maxWidthForMenu / 2):
					leadingMenuConstraint?.constant = -maxWidthForMenu
					dismiss = true
				case CGFloat(0.0)...(maxWidthForMenu):
					fallthrough
				default:
					leadingMenuConstraint?.constant = 0
				}
			}
			
			UIView.animateWithDuration(0.25, animations: { () -> Void in
				self.view.layoutIfNeeded()
				self.backgroundView?.alpha = dismiss ? 0.0 : self.maxAlpha
				}, completion: { (completed) -> Void in
					if dismiss {
						self.closeMenu(nil)
					}
					self.startingTouch = nil
					self.deltaX = 0
			})
		}
		
		
	}
	
}




















