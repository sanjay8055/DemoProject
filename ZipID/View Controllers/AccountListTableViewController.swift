//
//  AccountListTableViewController.swift
//  ZipID
//
//  Created by Damien Hill on 16/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

protocol AccountListDelegate {
    func didSelectAccount(account:Account)
}

class AccountListTableViewController: UITableViewController {
    
    var accounts: Array<Account> = []
    var delegate: AccountListDelegate?
    var selectedAccount: Account?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UITableView Data Source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "AccountCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        let account = accounts[indexPath.row]
        cell.textLabel?.text = account.name
        cell.accessoryType = account.id == selectedAccount?.id ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        cell.textLabel?.textColor = account.id == selectedAccount?.id ? tableView.tintColor : UIColor.blackColor()
        
        return cell
    }
    
    // MARK: UITableView Delegate
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedAccount = accounts[indexPath.row]
        delegate?.didSelectAccount(selectedAccount!)
        tableView.reloadData()
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}