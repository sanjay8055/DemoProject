//
//  JobViewController.swift
//  ZipID
//
//  Created by Damien Hill on 18/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Analytics
import MagicalRecord

class JobViewController: UIViewController, UIAlertViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, StepProcessDelegate, VerificationTypeListDelegate, DocumentListDelegate {
    var job: Job?
    var delegate: ZPModalViewControllerProtocol?
    
    @IBOutlet var firstName: UITextField?
    @IBOutlet var middleName: UITextField?
    @IBOutlet var lastName: UITextField?
    @IBOutlet var clientReference: UITextField?
    @IBOutlet var phone: UITextField?
    @IBOutlet var email: UITextField?

    @IBOutlet var verificationType: UITextField?
    @IBOutlet var verificationTypeLabel: UILabel?
    @IBOutlet var requiredDocuments: UITextField?
    @IBOutlet var genderSegmentedControl: UISegmentedControl?
    @IBOutlet var deleteButton: UIButton?
    @IBOutlet var dateOfBirthLabel: UILabel?
    @IBOutlet var datePicker: UIDatePicker?
    @IBOutlet var datePickerContainer: UIView?
    @IBOutlet var scrollView: UIScrollView?
    
    var dateOfBirth: NSDate?
    var isNewJob: Bool?
    var activeView: UIView?
    var selectedAccount: Account?
    var selectedVerificationType: ZPVerificationType?
    var selectedQuestionSets: Array<String>
    
    required init?(coder aDecoder: NSCoder) {
        selectedQuestionSets = []
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        isNewJob = (job == nil)
        
        // Report owner
        // Only show owner field if it's relevant, dont allow creation of jobs if they have no report owners configured
        let brokerFor = ZPSubscriber.sharedInstance().brokerFor as! Array<Account>
        if (brokerFor.count <= 0) {
            return self.dismiss(nil)
        }
        
        if (isNewJob!) {
            title = "New client"
            deleteButton?.hidden = true
            job = configureNewJob()
        } else {
            title = "Edit client"
            deleteButton?.hidden = false
        }

        if job?.agentForBusinessCode == nil {
            if let owner = ClientService.defaultOwner() {
                job?.agentForBusinessCode = String(owner.id)
            }
        }
        
        if let ownerId = job?.agentForBusinessCode, ownerIdInt = Int(ownerId), owner = ownerDetails(ownerIdInt) {
            selectAccount(owner)
        }
        
        if let verificationType = job?.verificationTypeObj {
            selectVerificationType(verificationType)
        }
        
        selectedQuestionSets = job?.selectedQuestionSets as! Array<String> // copy!
        
        renderUIFromJob(job)

        // To do: revalidate job data on initial load?
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JobViewController.keyboardDidShow(_:)),
            name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(JobViewController.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.requiredDocuments?.text = selectedQuestionSets.count > 0 ? selectedDocumentsAsString(selectedQuestionSets) : ""
        // To do: other UI may need to be updated here
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SEGAnalytics.sharedAnalytics().screen("Verification edit")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func renderUIFromJob(job: Job?) {
        firstName?.text = job?.firstName != nil ? job?.firstName : ""
        middleName?.text = job?.middleName != nil ? job?.middleName : ""
        lastName?.text = job?.lastName != nil ? job?.lastName : ""
        phone?.text = job?.phone != nil ? job?.phone : ""
        email?.text = job?.email != nil ? job?.email : ""
        clientReference?.text = job?.clientReference != nil ? job?.clientReference : ""
        datePicker?.maximumDate = NSDate()
        datePickerContainer?.alpha = 0
        dateOfBirthLabel?.text = ""
        genderSegmentedControl?.selectedSegmentIndex = job?.genderRaw == GenderMale ? 1 : 0
        if (job?.dateOfBirth != nil) {
            datePicker?.date = job!.dateOfBirth!
            dateChanged(datePicker)
        }
        requiredDocuments?.text = job?.selectedQuestionSets.count > 0 ? selectedDocumentsAsString(job?.selectedQuestionSets as! Array<String>) : ""
    }
    
    func configureNewJob() -> Job? {
        return ClientService.create()
    }
    
    func ownerDetails(accountId: Int) -> Account? {
        var owner: Account?
        for account in ZPSubscriber.sharedInstance().brokerFor as! Array<Account> {
            if account.id == accountId {
                owner = account
            }
        }
        return owner
    }
    
    func selectAccount(account: Account) {
        self.selectedAccount = account
//        agentForBusinessCode?.text = account.name
        if self.selectedVerificationType == nil {
            if let verificationTypeId = selectedAccount?.verificationTypes.first {
                let verificationType = ZPVerificationType.findById(verificationTypeId)
                self.selectVerificationType(verificationType)
            } else {
                // To do
            }
        }
    }
    
    func selectVerificationType(verificationType: ZPVerificationType) {
        if verificationType.verificationTypeId != selectedVerificationType?.verificationTypeId {
            // Keep docs only if switching between VOI rules but not for custom
            if let selectedVoiWizard = selectedVerificationType?.voiWizard {
                if !(verificationType.voiWizard && selectedVoiWizard) {
                    self.selectQuestionSets([])
                }
            }
            self.selectedVerificationType = verificationType
            self.verificationType?.text = verificationType.name
        }
        if let accountName = selectedAccount?.name {
            let verificationString = NSMutableAttributedString(string: "\(verificationType.name)\nfor \(accountName)")
            let range = NSRange(location: verificationType.name.characters.count, length: accountName.characters.count + 5)
            verificationString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12), range: range)
            verificationString.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: range)
            self.verificationTypeLabel?.attributedText = verificationString
        } else {
            self.verificationTypeLabel?.text = verificationType.name
        }
    }
    
    func selectQuestionSets(questionSets: Array<String>) {
        self.selectedQuestionSets = questionSets
        self.requiredDocuments?.text = questionSets.count > 0 ? selectedDocumentsAsString(questionSets) : ""
    }
    
    func selectedDocumentsAsString(questionSets: Array<String>) -> String {
        var qs = ZPQuestionSet.findMultipleById(questionSets, userSelectableOnly: true) as! Array<ZPQuestionSet>
        qs = qs.filter {$0.name != nil}
        let names: Array<String> = qs.map { $0.name }
        return names.joinWithSeparator(",")
    }
    
    func saveContext() {
        job?.firstName = firstName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        job?.middleName = middleName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        job?.lastName = lastName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let emailVal = email?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        job?.email = emailVal?.characters.count > 0 ? emailVal : nil
        
        let phoneVal = phone?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        job?.phone = phoneVal?.characters.count > 0 ? phoneVal : nil

        job?.clientReference = clientReference?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (selectedAccount != nil) {
            job?.agentForBusinessCode = String(selectedAccount!.id)
        } else {
            job?.agentForBusinessCode = nil
        }

        job?.verificationTypeObj = self.selectedVerificationType
        job?.verificationType = self.selectedVerificationType?.verificationTypeId
        job?.selectedQuestionSets = self.selectedQuestionSets

        job?.dateOfBirth = dateOfBirth
        
        if (genderSegmentedControl?.selectedSegmentIndex == 0) {
            job?.genderRaw = GenderFemale
        } else {
            job?.genderRaw = GenderMale
        }
        
        if (job!.hasSelectedDocuments) {
            job?.jobStatusRaw = JobStatusReady
        } else {
            job?.jobStatusRaw = JobStatusWaiting
        }
        
        NSUserDefaults.standardUserDefaults().setObject(job?.verificationType, forKey: "lastUsedVerificationType")
        NSUserDefaults.standardUserDefaults().synchronize()

        NSManagedObjectContext.MR_defaultContext().MR_saveToPersistentStoreWithCompletion { (success: Bool, error: NSError?) -> Void in
            // TODO: handle errors here
            NSNotificationCenter.defaultCenter().postNotificationName("didSaveJob", object: nil)
            
            if let verificationType = self.job?.verificationType, responseId = self.job?.jobGUID {
                SEGAnalytics.sharedAnalytics().track("Verification Created", properties: ["Response ID": responseId, "Verification type": verificationType])
            }
            
            // Clear practice mode if user has completed steps
            if (NSUserDefaults.standardUserDefaults().objectForKey("practiceCompleted") == nil) {
                let verificationCompleted = NSUserDefaults.standardUserDefaults().objectForKey("verificationCompleted") != nil
                let verificationUploaded = NSUserDefaults.standardUserDefaults().objectForKey("verificationUploaded") != nil
                if (verificationCompleted && verificationUploaded) {
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "practiceCompleted")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
            
            self.dismiss(nil)
        }
    }
    
    func dismiss(sender: AnyObject?) {
        if (delegate != nil) {
            delegate?.modalDidDismiss(self)
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
//    func validateUserInput(name: String, text: String?) -> String? {
//        let regex = try! NSRegularExpression(pattern: "[\\[\\]<>();/\\\\*=]", options: [])
//        var errorMessage: String?
//        
//        if (text != nil) {
//            let restrictedCharMatch = regex.firstMatchInString(text!, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, text!.characters.count)) != nil
//            if (restrictedCharMatch) {
//                errorMessage = name.stringByAppendingString(" must not contain any special characters including < > ( ) ; / \\ [ ] * =")
//            }
//        }
//        return errorMessage;
//    }
    
    // MARK: IBActions
    @IBAction func save(sender: AnyObject?) {
        var errorMessage: String?
        
        if (firstName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == ""){
            errorMessage = "First name is required"
        } else if (firstName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
                errorMessage = "First name is required"

        } else if (lastName?.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) == "") {
            errorMessage = "Last name is required"
        } else if (dateOfBirthLabel?.text == "") {
            errorMessage = "Date of birth is required"
        } else if (email?.text?.characters.count > 0 && !email!.text!.isEmail()) {
            errorMessage = "Invalid email address"
        }
        
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("First name", text: firstName?.text)
        }
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("Middle name", text: middleName?.text)
        }
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("Last name", text: lastName?.text)
        }
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("Phone", text: phone?.text)
        }
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("Email", text: email?.text)
        }
        if errorMessage == nil {
            errorMessage = UserInputHelper.validateUserInput("Reference", text: clientReference?.text)
        }
        
//        // what isn't working: \
//        let regex = try! NSRegularExpression(pattern: "[\\[\\]<>();/\\/]", options: [])
//        if let firstNameText = firstName?.text {
//            let restrictedCharMatchFirstName = regex.firstMatchInString(firstNameText, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, firstNameText.characters.count)) != nil
//            if (restrictedCharMatchFirstName) {
//                errorMessage = "First name must not contain any special characters including < > ( ) ; / \\ / [ ]"
//            }
//        }

        if (errorMessage != nil) {
            let alertView = UIAlertView(title: errorMessage!,
                message: nil,
                delegate: self,
                cancelButtonTitle: "Ok")
            alertView.show()
        } else {
            self.saveContext()
        }
    }
    
    @IBAction func dateChanged(sender: AnyObject?) {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateOfBirth = datePicker?.date
        dateOfBirthLabel!.text = dateFormatter.stringFromDate(dateOfBirth!)
    }
    
    @IBAction func showDatePicker(sender: AnyObject?) {
        view.endEditing(true)
        UIView.animateWithDuration(0.25) { () -> Void in
            self.datePickerContainer?.alpha = 1
        }
    }

    @IBAction func cancel(sender: AnyObject?) {
        if (isNewJob!) {
            deleteJob(sender)
            saveContext()
        } else {
            if (NSManagedObjectContext.MR_defaultContext().hasChanges) {
                NSManagedObjectContext.MR_defaultContext().undo()
            }
            self.dismiss(sender)
        }
    }
    
    @IBAction func deleteJob(sender: AnyObject?) {
        job?.MR_deleteEntity()
        saveContext()
    }

    @IBAction func hideKeyboard(sender: AnyObject?) {
        activeView?.resignFirstResponder()
    }

    @IBAction func hidePickerView(sender: AnyObject?) {
        if (datePickerContainer != nil) {
            UIView.animateWithDuration(0.26,
                animations: { () -> Void in
                    self.datePickerContainer?.alpha = 0
                }, completion: nil)
        }
    }
    
    @IBAction func selectDocuments(sender: AnyObject?) {
        hidePickerView(sender)
        if let voiWizard = self.selectedVerificationType?.voiWizard where voiWizard == true {
            let stepProcess = StepProcess.getStepProcess("voi-wizard-app", processType: StepProcessType.DocumentPicker)
            let vc = self.getInitialVCForStoryboard(stepProcess.storyboardName, universal: true) as! StepProcessNavigationController
            vc.stepProcessDelegate = self
            vc.stepProcess = stepProcess
            vc.templateModel = [String: AnyObject]()
            var personName: String?
            if (firstName!.text!.characters.count > 0) {
                vc.templateModel?["firstName"] = firstName!.text!
                personName = firstName!.text!
            }
            if (lastName!.text!.characters.count > 0) {
                vc.templateModel?["lastName"] = lastName!.text!
                if (personName != nil) {
                    personName = personName! + " " + lastName!.text!
                } else {
                    personName = lastName!.text!
                }
            }
            if (personName != nil) {
                vc.templateModel?["personName"] = personName!
            }
            vc.start()
            vc.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            self.presentViewController(vc, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("SelectDocuments", sender: sender)
        }
    }
    
    // MARK: Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        hidePickerView(sender)
        hideKeyboard(sender)

        var vc: UIViewController? = nil
        if (segue.destinationViewController.isKindOfClass(UINavigationController)) {
            let navVC = segue.destinationViewController as! UINavigationController
            vc = navVC.childViewControllers[0]
        } else {
            vc = segue.destinationViewController
        }
        
        if (vc!.respondsToSelector(Selector("setJob:"))) {
            vc!.performSelector(Selector("setJob:"), withObject: job!)
        }
        
        if (vc!.isKindOfClass(DocumentListTableViewController)) {
            let documentsListVC = vc as! DocumentListTableViewController
            if let verificationType = selectedVerificationType {
                documentsListVC.questionSets = ZPQuestionSet.findMultipleById(verificationType.questionSets, userSelectableOnly: true) as! Array<ZPQuestionSet>
                documentsListVC.selectedQuestionSets = self.selectedQuestionSets
            }
            documentsListVC.delegate = self
        }
        
        if (vc!.isKindOfClass(VerificationTypeListTableViewController)) {
            let verificationTypeListVC = vc as! VerificationTypeListTableViewController
            verificationTypeListVC.selectedVerificationType = self.selectedVerificationType
            verificationTypeListVC.selectedAccount = self.selectedAccount
            let accounts = ZPSubscriber.sharedInstance().brokerFor as! Array<Account>
            verificationTypeListVC.accounts = accounts
            verificationTypeListVC.delegate = self
        }
        
    }

    // MARK: UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        hideKeyboard(scrollView)
        hidePickerView(scrollView)
    }
   
    // MARK: UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        self.hidePickerView(textField)
        self.activeView = textField
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Notification Handlers
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo
        let kbSize = info![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        let contentInset = UIEdgeInsetsMake(0, 0, kbSize!.height, 0)
        scrollView?.contentInset = contentInset
        scrollView?.scrollIndicatorInsets = contentInset
        if (activeView != nil) {
            scrollView?.scrollRectToVisible(activeView!.frame, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView?.contentInset = contentInset
        scrollView?.scrollIndicatorInsets = contentInset
    }
    
    // MARK: StepProcessDelegate
    func didComplete(success: Bool, responses: Array<Response?>) {
        if (success) {
            self.selectQuestionSets(getDocumentList(responses))
        } else {
            self.selectQuestionSets([])
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func getDocumentList(responses: Array<Response?>) -> Array<String> {
        var documentList: Array<String> = []
        for response in responses {
            if (response?.responseType == ResponseType.DocumentList) {
                documentList.appendContentsOf(response!.response as! Array<String>)
            }
        }
        return documentList
    }
    
    // MARK: VerificationTypeListDelegate
    func didSelectVerificationType(verificationType: ZPVerificationType, account: Account) {
        self.selectAccount(account)
        self.selectVerificationType(verificationType)
    }
    
    // MARK: DocumenListDelegate
    func didSelectQuestionSets(questionSets: Array<String>) {
        self.selectQuestionSets(questionSets)
        dismissViewControllerAnimated(true, completion: nil)
    }

}
