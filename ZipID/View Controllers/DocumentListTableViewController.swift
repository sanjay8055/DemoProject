//
//  DocumentListTableViewController.swift
//  ZipID
//
//  Created by Damien Hill on 2/05/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import Analytics

protocol DocumentListDelegate {
    func didSelectQuestionSets(questionSets:Array<String>)
    func didCancel()
}

class DocumentListTableViewController: UITableViewController {
    
    var questionSets: Array<ZPQuestionSet> = []
    var delegate: DocumentListDelegate?
    var selectedQuestionSets: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.SEGAnalytics.sharedAnalytics().screen("Document list")
    }
    
    @IBAction func done() {
        delegate?.didSelectQuestionSets(selectedQuestionSets)
    }
    
    @IBAction func cancel() {
        delegate?.didCancel()
    }
    
    // MARK: UITableView Data Source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionSets.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "DocumentCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DocumentCell
        
        let questionSet = questionSets[indexPath.row]
        cell.documentLabel?.text = questionSet.name
        if self.selectedQuestionSets.contains(questionSet.questionSetId) {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: UITableViewScrollPosition.None)
        }
       
        return cell
    }
    
    // MARK: UITableView Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let questionSet = questionSets[indexPath.row]
        if !self.selectedQuestionSets.contains(questionSet.questionSetId) {
            self.selectedQuestionSets.append(questionSet.questionSetId)
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let questionSet = questionSets[indexPath.row]
        if let index = selectedQuestionSets.indexOf(questionSet.questionSetId) {
            selectedQuestionSets.removeAtIndex(index)
        }
    }
    
}