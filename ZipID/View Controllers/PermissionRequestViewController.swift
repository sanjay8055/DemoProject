//
//  PermissionRequestViewController.swift
//  ZipID
//
//  Created by Damien Hill on 14/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import ISHPermissionKit

@objc class PermissionRequestViewController: ISHPermissionRequestViewController {

    @objc var goToSettings: Bool = false
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var allowButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title: String
        let text: String
        let allowButtonLabel: String
        let iconName: String
        
        switch permissionCategory {
            case .LocationWhenInUse:
                title = "Location"
                text = "ZipID needs access to your location while interviewing clients for inclusion in your verification report."
                allowButtonLabel = "Allow location access"
                iconName = "permission-location"
            break
            case .PhotoCamera:
                title = "Camera"
                text = "ZipID needs access to the camera so you can take photos of documents and the client."
                allowButtonLabel = "Enable camera"
                iconName = "permission-camera"
            break
            default:
                title = "Permission"
                text = ""
                allowButtonLabel = "Allow"
                iconName = "permission-location"
            break
        }

        titleLabel.text = title
        textLabel.text = text
        allowButton.setTitle(allowButtonLabel, forState: UIControlState.Normal)
        allowButton.layer.cornerRadius = 25
        allowButton.layer.masksToBounds = true
        iconImageView.image = UIImage(named: iconName)
    }
    
    @IBAction private func allow(sender: AnyObject) {
        if goToSettings == true {
            openSettings()
        } else {
            requestPermissionFromSender(sender)
        }
    }
    
    @IBAction private func decline(sender: AnyObject) {
        changePermissionStateToAskAgainFromSender(sender)
        if goToSettings == true {
            // No delegate in this scenario so vc dismisses itself
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func openSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string:
            UIApplicationOpenSettingsURLString)!)
        dismissViewControllerAnimated(false, completion: nil)
    }
    
}