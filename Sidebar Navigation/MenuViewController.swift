//
//  MenuViewController.swift
//  Sidebar Navigation
//

import UIKit

protocol MainMenuDelegate: class {
	func didSelectCell(cell: MenuCell)
	var selectedIndex: Int? { get set }
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var menuDataArray: [MenuCell] = [
		MenuCell(controllerIdentifier: "FirstController", cellTitle: "First"),
		MenuCell(controllerIdentifier: "SecondController", cellTitle: "Second"),
		MenuCell(controllerIdentifier: "ThirdController", cellTitle: "Third")
	]
	
	weak var delegate: MainMenuDelegate?
	private weak var tableView: UITableView!
	var parentView: UIView! {
		return self.parentViewController?.view ?? self.view
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		setupView()
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
		setupView()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition({ (context) -> Void in
			self.drawShadow()
			}, completion: nil)
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
	}
	
	func setupView() {
		let tableView = UITableView(frame: CGRectZero)
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		tableView.delegate = self
		tableView.dataSource = self
		view.addSubview(tableView)
		self.tableView = tableView
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
		view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
	}
	
	func drawShadow() {
		parentView?.clipsToBounds = false
		parentView?.layer.shadowOpacity = 0.5
		parentView?.layer.shadowRadius = 2.0
		parentView?.layer.shadowOffset = CGSizeMake(2.0, 0.0)
		parentView?.layer.shadowPath = UIBezierPath(rect: view.bounds).CGPath
	}
	
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuDataArray.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
		cell.textLabel?.text = menuDataArray[indexPath.row].cellTitle
		return cell
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		return 60
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row == delegate?.selectedIndex {
			cell.setSelected(true, animated: false)
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		delegate?.selectedIndex = indexPath.row
		delegate?.didSelectCell(menuDataArray[indexPath.row])
	}
}



























