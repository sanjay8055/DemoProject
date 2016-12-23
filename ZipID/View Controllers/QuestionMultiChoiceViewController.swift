//
//  QuestionMultiChoiceViewController.swift
//  ZipID
//
//  Created by Damien Hill on 10/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Mustache

@objc class QuestionMultiChoiceViewController: ZPQuestionViewController, UITableViewDelegate, UITableViewDataSource {
    
    var question: ZPQuestion?
    var selectedOptions: Array<Int> = []
    var multiSelect: Bool = false
    @IBOutlet var tableView: UITableView?
    @IBOutlet var titleLabel: UILabel?

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let question = self.job.questions?[NSInteger(questionIndex)] as? ZPQuestion {
            self.question = question
            renderTitle()
        }
    }
    
    // MARK: Render
    private func renderTitle() {
        let templateModel = self.job.dictionaryForMergeFields() as! Dictionary<String, AnyObject>
        if (question?.question != nil) {
            let renderedTitle: String?
            do {
                let template = try Template(string: question!.question)
                renderedTitle = try template.render(Box(templateModel))
            } catch _ {
                renderedTitle = nil
            }
            if (renderedTitle != nil) {
                titleLabel?.text = renderedTitle!
            } else {
                titleLabel?.text = question?.question
            }
        } else {
            titleLabel?.hidden = true
        }
    }
    
    // MARK: User interactions
    @IBAction func toggleOption(optionIndex: Int) {
        if (!multiSelect) {
            selectedOptions = [optionIndex]
        } else {
            if (!selectedOptions.contains(optionIndex)) {
                selectedOptions.append(optionIndex)
            } else {
                if let existingOptionIndex = selectedOptions.indexOf(optionIndex) {
                    selectedOptions.removeAtIndex(existingOptionIndex)
                }
            }
        }
        toggleCheckmarks()
        self.hasResponse = validateOptions(selectedOptions)
    }
    
    func validateOptions(options: Array<Int>) -> Bool {
        return options.count > 0
    }
    
    func toggleCheckmarks() {
        if let options = self.question?.options as? Array<Dictionary<String, AnyObject>> {
            for index in 0...options.count {
                let cell = tableView?.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
                cell?.accessoryType = selectedOptions.contains(index) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
                cell?.textLabel?.textColor = selectedOptions.contains(index) ? tableView?.tintColor : UIColor.blackColor()
            }
        }
    }
    
    // MARK: Question View Controller
    override func saveToResponse() {
        if let documentId = question?.documentId {
            // TODO: support for multi-select multichoice
            if let options = self.question?.options as? Array<Dictionary<String, AnyObject>> {
                for selectedIndex in self.selectedOptions {
                    let response = ZPTextResponse()
                    response.text = options[selectedIndex]["label"] as? String
                    response.label = question?.title
                    response.key = documentId
                    surveyResponse.additionalStepsResponsesDictionary.setObject(response, forKey: documentId)
                }
            }
        }
        super.saveToResponse()
    }
    
    override func removeFromResponse() {
        if let documentId = question?.documentId {
            surveyResponse.additionalStepsResponsesDictionary.removeObjectForKey(documentId)
        }
        super.saveToResponse()
    }
    
    // MARK: UITableView Data Source
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let textCellIdentifier = "OptionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        
        if let options = self.question?.options as? Array<Dictionary<String, AnyObject>> {
            let option = options[indexPath.row]
            cell.textLabel?.text = option["label"] as? String
            cell.accessoryType = selectedOptions.contains(indexPath.row) ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = selectedOptions.contains(indexPath.row) ? tableView.tintColor : UIColor.blackColor()
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = question?.options.count {
            return rows
        } else {
            return 0
        }
    }
    
    // MARK: UITableView Delegate
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        toggleOption(indexPath.row)
        return indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}