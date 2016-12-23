//
//  VerificationTypeListTableViewController.swift
//  ZipID
//
//  Created by Damien Hill on 2/05/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//


import Foundation
import Analytics

protocol VerificationTypeListDelegate {
    func didSelectVerificationType(verificationType:ZPVerificationType, account:Account)
}

class VerificationTypeListTableViewController: UITableViewController {
    
    var accounts: Array<Account> = []
    var delegate: VerificationTypeListDelegate?
    var selectedVerificationType: ZPVerificationType?
    var selectedAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.SEGAnalytics.sharedAnalytics().screen("Verification type list")
    }
    
    // MARK: UITableView Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let account = accounts[section]
        return account.verificationTypes.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return accounts[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "VerificationTypeCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VerificationTypeCell
        
        let account = accounts[indexPath.section]
        let verificationTypeId = account.verificationTypes[indexPath.row]
        let verificationType = ZPVerificationType.findById(verificationTypeId)
        if verificationType != nil {
            cell.verificationTypeLabel?.text = verificationType.name
            cell.userInteractionEnabled = true
            cell.hidden = false
            if verificationType.verificationTypeId == selectedVerificationType?.verificationTypeId && account.id == selectedAccount?.id {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                cell.verificationTypeLabel?.textColor = tableView.tintColor
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
                cell.verificationTypeLabel?.textColor = UIColor.blackColor()
            }
            if verificationType.icon != nil {
                var baseUrl = "https://zipid.com.au"
                #if DEV
                    baseUrl = "https://localhost:3001"
                #endif
                #if TEST
                    baseUrl = "https://test.zipid.com.au"
                #endif
                cell.icon?.setImageWithURL(NSURL(string: "\(baseUrl)\(verificationType.icon)")!)
            } else {
                cell.icon?.image = nil
            }
        } else {
            // Missing verification type in list
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.verificationTypeLabel?.textColor = UIColor.blackColor()
            cell.icon?.image = nil
            cell.verificationTypeLabel?.text = ""
            cell.userInteractionEnabled = false
            cell.hidden = true
        }
        return cell
    }
    
    // MARK: UITableView Delegate
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedAccount = accounts[indexPath.section]
        let verificationTypeId = selectedAccount!.verificationTypes[indexPath.row]
        selectedVerificationType = ZPVerificationType.findById(verificationTypeId)
        delegate?.didSelectVerificationType(selectedVerificationType!, account:selectedAccount!)
        tableView.reloadData()
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}