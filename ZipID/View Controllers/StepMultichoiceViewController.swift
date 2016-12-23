//
//  StepMultichoiceViewController.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

class StepMultichoiceViewController: StepViewController {
    
    @IBOutlet var buttonGroupView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        renderStep(step)
    }
    
    func selectOption(sender: UIButton) {
        let option:StepOption? = step!.allOptions()[sender.tag]
        
        if (option?.docs != nil) {
            response = Response(responseType: ResponseType.DocumentList)
            response?.response = option!.docs!
        }
        delegate?.didSelectNext(step!, option: option, viewController: self)
    }
 
    // MARK: Render
    func renderStep(step: Step?) {
        let marginY: CGFloat = 5
        var originY: CGFloat = 0
        for optionGroup in (step?.optionGroups)! {
            if (optionGroup.title != nil) {
                originY = renderGroupTitle(originY, optionGroup: optionGroup) + marginY
            }
            for option in (optionGroup.options)! {
                originY = renderButton(originY, option: option) + marginY
            }
            originY += (marginY * 2)
        }
    }
    
    func renderGroupTitle(originY: CGFloat, optionGroup: StepOptionGroup) -> CGFloat {
        let size = CGSizeMake(300, 40)
        let label: UILabel = UILabel(frame: CGRectMake(0, originY, size.width, size.height))
        label.center = CGPointMake(view.center.x, originY)
        label.text = optionGroup.title
        label.textAlignment = NSTextAlignment.Center
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = UIFont.boldSystemFontOfSize(17)
        buttonGroupView?.addSubview(label)
        return originY + size.height
    }
    
    func renderButton(originY: CGFloat, option: StepOption) -> CGFloat {
        let size = CGSizeMake(300, 54)
        let button: UIButton = UIButton(type: UIButtonType.System)
        button.frame = CGRectMake(0, originY, size.width, size.height)
        button.center = CGPointMake(view.center.x, originY)
        button.setTitle(option.name, forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(StepMultichoiceViewController.selectOption(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.titleLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
        button.titleLabel!.textAlignment = NSTextAlignment.Center
        button.titleLabel!.font = UIFont.systemFontOfSize(17)
        button.tag = option.optionId
        buttonGroupView?.addSubview(button)
        return originY + size.height
    }

    
}