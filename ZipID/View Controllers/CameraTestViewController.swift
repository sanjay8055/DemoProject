//
//  CameraTestViewController.swift
//  ZipID
//
//  Created by Damien Hill on 8/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

@objc protocol CameraTestDelegate {
    func didSelectImage(image: UIImage)
    func didCancel()
}

class CameraTestViewController: UIViewController, IPDFCameraViewControllerDelegate {

    @IBOutlet var progressView: UIProgressView?
    @IBOutlet var cameraViewController: IPDFCameraViewController?
    @IBOutlet var focusIndicator: UIImageView?
    @IBOutlet var captureImageView: UIImageView?
    @IBOutlet var doneButton: UIButton?
    @IBOutlet var cancelButton: UIButton?
    @IBOutlet var retakeButton: UIButton?
    @IBOutlet var adjustBar: UIView?
    var delegate: CameraTestDelegate?
    
    // MARK: View lifecycle    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraViewController?.delegate = self
        cameraViewController?.enableAutoCapture = true
        cameraViewController?.targetAspectRatio = 1.75
        cameraViewController?.setupCameraView()
        cameraViewController?.enableBorderDetection = true
        cameraViewController?.cameraViewType = IPDFCameraViewType.Normal
        progressView?.setProgress(0, animated: false)
        progressView?.trackTintColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        cameraViewController?.start()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: Camera VC actions
    @IBAction func focusGesture(sender: UITapGestureRecognizer?) {
        if (sender?.state == UIGestureRecognizerState.Recognized) {
            if let location = sender?.locationInView(self.cameraViewController) {
                focusIndicatorAnimateToPoint(location)
                cameraViewController?.focusAtPoint(location, completionHandler: { () -> Void in
                    self.focusIndicatorAnimateToPoint(location)
                })
            }
        }
    }
    
    func focusIndicatorAnimateToPoint(targetPoint: CGPoint) {
        focusIndicator?.center = targetPoint
        focusIndicator?.alpha = 0.0
        focusIndicator?.hidden = false
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.focusIndicator?.alpha = 1.0
            }) { (finished: Bool) -> Void in
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    self.focusIndicator?.alpha = 0.0
                })
        }
    }
    
    // MARK: CameraVC Capture Image
    @IBAction func captureButton(sender: AnyObject?) {
        cameraViewController?.captureImage()
    }
    
    func dismissPreview() {
        cameraViewController?.start()
        self.retakeButton?.hidden = true
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.captureImageView?.frame = CGRectOffset(self.view.bounds, 0, self.view.bounds.height)
            }) { (finished: Bool) -> Void in
                self.captureImageView?.removeFromSuperview()
                self.doneButton?.hidden = true
                self.cancelButton?.hidden = false
        }
    }
    
    // MARK: IPDF Camera Delegate
    func takeSnapshotWithPath(imageFilePath: String!) {
        if (self.captureImageView != nil) {
            self.captureImageView?.removeFromSuperview()
            self.captureImageView = nil
        }
        self.captureImageView = UIImageView(image: UIImage(contentsOfFile: imageFilePath))
        self.captureImageView!.backgroundColor = UIColor(hex: 0x000000, alpha: 1.0)
        self.captureImageView!.frame = CGRectOffset(self.view.bounds, 0, -self.view.bounds.size.height)
        self.captureImageView!.alpha = 1.0
        self.captureImageView!.contentMode = UIViewContentMode.ScaleAspectFit
        self.captureImageView!.userInteractionEnabled = true
        self.view.insertSubview(self.captureImageView!, belowSubview: self.adjustBar!)
        self.cameraViewController?.stop()
        self.retakeButton?.hidden = false
        self.doneButton?.hidden = false
        self.cancelButton?.hidden = true
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.captureImageView!.frame = self.view.bounds
        }, completion: nil)
    }
    
    func autoCaptureProgress(progress: Float) {
        dispatch_async(dispatch_get_main_queue()) {
            self.progressView?.setProgress(progress, animated: true)
        }
    }
    
    // MARK: Key actions
    @IBAction func retakeImage(sender: AnyObject?) {
        self.progressView?.setProgress(0, animated: false)
        cameraViewController?.resumeCapture()
        dismissPreview()
    }
    
    @IBAction func cancel(sender: AnyObject?) {
        delegate?.didCancel()
    }
    
    @IBAction func usePhoto(sender: AnyObject?) {
        delegate?.didSelectImage(captureImageView!.image!)
    }
    
}