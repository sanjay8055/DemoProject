//
//  StepTableViewController.swift
//  ZipID
//
//  Created by Damien Hill on 20/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Mustache

class StepTableViewController: UITableViewController, StepProtocol {
    
    var step: Step?
    var delegate: StepDelegate?
    var response: Response?
    var templateModel: Dictionary<String, AnyObject>?    
    @IBOutlet var nextButton: UIBarButtonItem?
    @IBOutlet var titleLabel: UILabel?
    var showCancelButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderTitle()
        if (!showCancelButton) {
            navigationItem.leftBarButtonItem = nil
        }
        self.clearsSelectionOnViewWillAppear = true
    }
    
    // MARK: IBActions
    @IBAction func nextStep(sender: AnyObject?) {
        delegate?.didSelectNext(step!, option: nil, viewController: self)
    }
    
    @IBAction func cancel(sender: AnyObject?) {
        delegate?.didCancel()
    }
    
    // MARK: Render
    private func renderTitle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        if (step?.title != nil) {
            let renderedTitle: String?
            do {
                let template = try Template(string: step!.title!)
                renderedTitle = try template.render(Box(templateModel))
            } catch _ {
                renderedTitle = nil
            }
            if (renderedTitle != nil) {
                titleLabel?.text = renderedTitle!
            } else {
                titleLabel?.text = step?.title
            }
        } else {
            self.tableView.tableHeaderView?.frame = CGRectMake(0, 0, tableView.frame.size.width, 0)
            titleLabel?.hidden = true
        }
    }
    
    // MARK: StepProtocol
    func getResponse() -> Response? {
        return self.response
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = step?.optionGroups?.count {
            return sections
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = step?.optionGroups?[section].options?.count {
            return rows
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return step?.optionGroups?[section].title
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let option = step?.optionGroups?[indexPath.section].options?[indexPath.row]
        let renderedName: String?
        if (option?.name != nil) {
            do {
                let template = try Template(string: option!.name)
                renderedName = try template.render(Box(templateModel))
            } catch _ {
                renderedName = nil
            }
        } else {
            renderedName = nil
        }
        if (renderedName != nil && renderedName!.characters.count > 60) {
            return tableView.rowHeight * 1.25
        } else {
            return tableView.rowHeight
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let option = step?.optionGroups?[indexPath.section].options?[indexPath.row]
        
        let cellIdentifier: String
        if (option?.subtitle != nil) {
            cellIdentifier = "OptionDetailCell"
        } else {
            cellIdentifier = "OptionCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)

        if (option != nil) {
            let renderedName: String?
            do {
                let template = try Template(string: option!.name)
                renderedName = try template.render(Box(templateModel))
            } catch _ {
                renderedName = nil
            }
            if (renderedName != nil) {
                cell.textLabel?.text = renderedName!
            } else {
                cell.textLabel?.text = option!.name
            }
            cell.detailTextLabel?.text = option?.subtitle
            cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
            cell.textLabel?.numberOfLines = 0
            if (option?.iconName != nil) {
                cell.imageView?.image = UIImage(named: option!.iconName!)
            } else {
                cell.imageView?.image = nil
            }
        }
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let option = step?.optionGroups?[indexPath.section].options?[indexPath.row] {
            if (option.docs != nil) {
                response = Response(responseType: ResponseType.DocumentList)
                response?.response = option.docs!
            } else {
                response = nil
            }
            delegate?.didSelectNext(step!, option: option, viewController: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}