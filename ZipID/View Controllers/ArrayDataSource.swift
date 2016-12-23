//
//  ArrayDataSource.swift
//  ZipID
//
//  Created by Damien Hill on 16/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

class ArrayDataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    let cellIdentifier: String
    let configureCell: ((UITableViewCell, item: AnyObject) -> Void)?
    let deleteItem: ((AnyObject) -> Void)?
    let editable: Bool
    let fetchedResultsController: NSFetchedResultsController
    let tableView: UITableView
    var itemCount: Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[0]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    init(cellIdentifier: String,
         editable: Bool,
         fetchedResultsController: NSFetchedResultsController,
         tableView: UITableView,
         configureCell: ((UITableViewCell, item: AnyObject) -> Void)?,
         deleteItem: ((AnyObject) -> Void)?) {
        self.cellIdentifier = cellIdentifier
        self.configureCell = configureCell
        self.editable = editable
        self.deleteItem = deleteItem
        self.fetchedResultsController = fetchedResultsController
        self.tableView = tableView
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
    func itemAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        if let sections = fetchedResultsController.sections?.count,
            let rows = fetchedResultsController.sections?[indexPath.section].numberOfObjects {
            if sections > indexPath.section && rows > indexPath.row {
                return fetchedResultsController.objectAtIndexPath(indexPath)
            }
        }
        return nil
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let item = fetchedResultsController.objectAtIndexPath(indexPath)
        configureCell?(cell, item: item)
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return editable
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            print("Deleting item")
            if let item = itemAtIndexPath(indexPath) {
                deleteItem?(item)
            }
        }
    }
    
    // MARK: -
    // MARK: Fetched Results Controller Delegate Methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            break;
        case .Update:
            if let indexPath = indexPath {
                if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                    print("Updating item")
                    if let item = itemAtIndexPath(indexPath) {
                        configureCell?(cell, item: item)
                    }
                }
            }
            break;
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            }
            break;
        }
    }
    
}