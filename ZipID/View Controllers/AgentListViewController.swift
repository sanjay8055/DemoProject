//
//  AgentListViewController.swift
//  ZipID
//
//  Created by Damien Hill on 16/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import Analytics

class AgentListViewController: UITableViewController, AgentViewControllerDelegate {
   
    var job: Job!
    private var selectedAgent: Agent?
    private var agentArrayDataSource: ArrayDataSource?
    @IBOutlet private var nextButton: UIBarButtonItem!
    
    // MARK: -
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.accessibilityIdentifier = "Verifier list"
        setupTableView()
        selectFirstAgent()
        startLocationServices()
        #if !ENTERPRISE
            createDefaultAgent()
        #endif
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.SEGAnalytics.sharedAnalytics().screen("Agent list")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navBar = navigationController?.navigationBar as? ZPNavigationBarWithProgress {
            let progress = Float(1) / Float(job.questions.count + 3)
            navBar.updateProgress(progress)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let agent = selectedAgent {
            agent.dateUsed = NSDate()
        }
    }
    
    // MARK: -
    // MARK: Setup
    private func startLocationServices() {
        let locationPermissionRequest = ISHPermissionRequest(forCategory: .LocationWhenInUse)
        if locationPermissionRequest.permissionState() == .Authorized {
            ZPLocationService.sharedInstance().startUpdating()
        }
    }
    
    private func createDefaultAgent() {
        if (agentArrayDataSource?.itemCount <= 0) {
            deselectAgent()
            createAgentFromUser({ agent in
                self.selectFirstAgent()
            })
        }
    }
    
    private func selectFirstAgent() {
        if let agent = agentArrayDataSource?.itemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? Agent {
            selectAgent(agent)
        }
    }
    
    private func createAgentFromUser(complete: (Agent?) -> ()) {
        if let firstName = ZPSubscriber.sharedInstance().agentFirstName {
            if let newAgent = Agent.MR_createEntity() {
                newAgent.firstName = firstName
                if let lastName = ZPSubscriber.sharedInstance().agentLastName {
                    newAgent.lastName = lastName
                }
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({ (success, error) in
                        complete(newAgent)
                })
            }
        }
    }
    
    private func setupTableView() {
        let fetchRequest = NSFetchRequest(entityName: "Agent")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateUsed", ascending: false)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: NSManagedObjectContext.MR_defaultContext(),
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        func configureCell(cell: UITableViewCell, item: AnyObject) {
            if let agent = item as? Agent {
                cell.textLabel?.text = "\(agent.firstName) \(agent.lastName)"
                if agent == selectedAgent {
                    cell.accessoryType = .Checkmark
                    cell.textLabel?.textColor = tableView.tintColor
                } else {
                    cell.accessoryType = .None
                    cell.textLabel?.textColor = UIColor.blackColor()
                }
            }
        }
        
        func deleteItem(item: AnyObject) {
            if let agent = item as? Agent {
                if agent == self.selectedAgent {
                    deselectAgent()
                }
                agent.MR_deleteEntity()
                NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion({ (success: Bool, error: NSError?) in
                })
            }
        }
        
        agentArrayDataSource = ArrayDataSource(cellIdentifier: "Agent",
                                               editable: true,
                                               fetchedResultsController: fetchedResultsController,
                                               tableView: tableView,
                                               configureCell: configureCell,
                                               deleteItem: deleteItem)
        
        self.tableView.dataSource = agentArrayDataSource
        do {
            try agentArrayDataSource?.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }

    }
    
    // MARK: -
    // MARK: Interactions
    func selectAgent(agent: Agent) {
        selectedAgent = agent
        nextButton.enabled = true
        tableView.reloadData()
    }
    
    func deselectAgent() {
        selectedAgent = nil
        nextButton.enabled = false
    }
    
    @IBAction func next(sender: AnyObject?) {
        if (job.questions == nil) {
            let alert = UIAlertView(title: "Error",
                                    message: "We could not begin verification, please restart the app and ensure you are connected to the internet and also have the latest version of the ZipID app.",
                                    delegate: nil,
                                    cancelButtonTitle: "Okay")
            alert.show()
            return
        }
        
        job.dateStarted = NSDate()
        let firstQuestion = job.questions.first
        let viewName = firstQuestion?.getViewName()
        let surveyResponse = ZPSurveyResponse()
        surveyResponse.job = job
        if let agent = selectedAgent {
            job.agentName = "\(agent.firstName) \(agent.lastName)"
        }
        
        if let vc = self.getView(viewName, forStoryboard: "Questions", universal: true) as? ZPQuestionViewController {
            vc.questionIndex = 0
            vc.job = job
            vc.surveyResponse = surveyResponse
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "NewAgent" {
            if let navVC = segue.destinationViewController as? UINavigationController,
                agentVC = navVC.childViewControllers.first as? AgentViewController {
                agentVC.delegate = self
            }
        }
    }
    
    // MARK: -
    // MARK: Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let agent = agentArrayDataSource?.itemAtIndexPath(indexPath) as? Agent {
            selectAgent(agent)
        }
    }
    
    // MARK: -
    // MARK: Agent View Controller Delegate
    func didAddAgent(agent: Agent) {
        selectAgent(agent)
    }

}
