//
//  AgentViewController.swift
//  ZipID
//
//  Created by Damien Hill on 24/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import Analytics

protocol AgentViewControllerDelegate {
    func didAddAgent(agent: Agent)
}

class AgentViewController: UIViewController {
    
    var delegate: AgentViewControllerDelegate?
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        dispatch_async(dispatch_get_main_queue()) {
            self.firstNameField.becomeFirstResponder()
        }
        SEGAnalytics.sharedAnalytics().screen("Agent detail")
    }
    
    @IBAction private func save(sender: AnyObject?) {
        let firstName = firstNameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let lastName = lastNameField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        var errorMessage: String?
        
        if firstName == "" {
            errorMessage = "First name is required"
        }
        
        if (errorMessage == nil) {
            errorMessage = UserInputHelper.validateUserInput("First name", text: firstName)
        }
        if (errorMessage == nil) {
            errorMessage = UserInputHelper.validateUserInput("Last name", text: lastName)
        }
        
        if (errorMessage != nil) {
            let alert = UIAlertView(title: errorMessage, message: nil, delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        if let agent = Agent.MR_createEntity() {
            agent.firstName = firstName
            agent.lastName = lastName
            agent.dateUsed = NSDate()
        
            NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion { (success: Bool, error: NSError?) in
                if success {
                    self.delegate?.didAddAgent(agent)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
}