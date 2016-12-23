//
//  LandscapeNavigationController.swift
//  ZipID
//
//  Created by Damien Hill on 1/03/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

class LandscapeNavigationController: UINavigationController {
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            return UIInterfaceOrientationMask.LandscapeRight
        } else {
            return super.supportedInterfaceOrientations()
        }
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            return UIInterfaceOrientation.LandscapeRight
        } else {
            return super.preferredInterfaceOrientationForPresentation()
        }
    }
    
    override func shouldAutorotate() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            return false
        } else {
            return super.shouldAutorotate()
        }
    }
    
}