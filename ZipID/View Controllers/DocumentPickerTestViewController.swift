//
//  DocumentPickerTestViewController.swift
//  ZipID
//
//  Created by Damien Hill on 18/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

class DocumentPickerTestViewController: UIViewController, StepProcessDelegate {
    
    @IBOutlet var documentPickerButton: UIButton?
    @IBOutlet var selectedDocumentsLabel: UILabel?
    
    @IBAction func showDocumentPicker() {
        let stepProcess = StepProcess.getStepProcess("voi-wizard", processType: StepProcessType.DocumentPicker)
        
        let vc = self.getInitialVCForStoryboard(stepProcess.storyboardName, universal: true) as! StepProcessNavigationController
        vc.stepProcessDelegate = self
        vc.stepProcess = stepProcess
        vc.start()
        self.presentViewController(vc, animated: true, completion: nil)
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
    
    // MARK: StepProcessDelegate
    func didComplete(success: Bool, responses: Array<Response?>) {
        if (success) {
            let documentList = getDocumentList(responses).joinWithSeparator(", ")
            selectedDocumentsLabel?.text = documentList
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didCancel() {
        print("Did cancel")
        dismissViewControllerAnimated(true, completion: nil)
    }
}