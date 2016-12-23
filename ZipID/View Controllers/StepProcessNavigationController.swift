//
//  StepProcessNavigationController.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation
import Analytics

class StepProcessNavigationController: UINavigationController, StepDelegate, UINavigationControllerDelegate {
    
    var stepProcess: StepProcess?
    var templateModel: Dictionary<String, AnyObject>?
    var responses: Array<Response?> = []
    var currentVC: UIViewController?
    var stepIndex: Int = 0
    var stepProcessDelegate: StepProcessDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.SEGAnalytics.sharedAnalytics().screen("Document wizard")
    }
    
    func start() {
        let startStep = stepProcess!.startStep()
        pushStep(startStep, animated:false)
    }
   
    private func pushStep(step:Step, animated: Bool) {
        if (step.template == "multichoice") {
            let vc = self.getView(step.template, forStoryboard: stepProcess!.storyboardName, universal: true) as! StepTableViewController
            vc.step = step
            vc.templateModel = templateModel
            vc.delegate = self
            if (childViewControllers.count == 0) {
                vc.showCancelButton = true
                vc.title = "Choose documents"
            }
            self.pushViewController(vc, animated: animated)
        } else {
            let vc = self.getView(step.template, forStoryboard: stepProcess!.storyboardName, universal: true) as! StepViewController
            vc.step = step
            vc.templateModel = templateModel
            vc.delegate = self
            self.pushViewController(vc, animated: animated)
        }
    }
    
    private func nextStep(step: Step, option: StepOption?, response: Response?) {
        if (option != nil) {
            let next = stepProcess!.steps[option!.next]!
            pushStep(next, animated: true)
        } else {
            let next = stepProcess!.steps[step.next!]!
            pushStep(next, animated: true)
        }
    }
    
    private func prevStep() {
        responses.popLast()
        stepIndex -= 1
    }
    
    private func appendResponse(response: Response?) {
        self.responses.append(response)
        stepIndex += 1
    }
    
    // MARK: StepDelegate
    func didSelectNext(step: Step, option: StepOption?, viewController: StepProtocol) {
        appendResponse(viewController.getResponse())
        
        if (step.success != nil) {
            stepProcessDelegate?.didComplete(step.success!, responses: responses)
        } else {
            nextStep(step, option: option, response: viewController.getResponse())
        }
    }
    
    func didCancel() {
        stepProcessDelegate?.didCancel()
    }

    // MARK: UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        if (stepIndex > 0 && viewController == navigationController.viewControllers[stepIndex - 1]) {
            prevStep()
        }
    }
    
}