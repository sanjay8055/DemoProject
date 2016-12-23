//
//  StepViewController.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Mustache

class StepViewController: UIViewController, StepProtocol {
    
    var step: Step?
    var delegate: StepDelegate?
    var response: Response?
    var templateModel: Dictionary<String, AnyObject>?
    @IBOutlet var nextButton: UIButton?
    @IBOutlet var stepTitleLabel: UILabel?
    @IBOutlet var bodyLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (step?.body != nil) {
            let renderedBody: String?
            do {
                let template = try Template(string: step!.body!)
                renderedBody = try template.render(Box(nil))
            } catch _ {
                renderedBody = nil
            }
            if (renderedBody != nil) {
                bodyLabel?.text = renderedBody!
            } else {
                bodyLabel?.text = step!.body
            }
        } else {
            bodyLabel?.text = ""
        }
        
        stepTitleLabel?.text = step!.title

        if (step?.next == nil) {
            nextButton?.hidden = true
        }
    }

    @IBAction func nextStep(sender: AnyObject?) {
        delegate?.didSelectNext(step!, option: nil, viewController: self)
    }
    
    @IBAction func cancel(sender: AnyObject?) {
        delegate?.didCancel()
    }
   
    // MARK: StepProtocol
    func getResponse() -> Response? {
        return self.response
    }
}