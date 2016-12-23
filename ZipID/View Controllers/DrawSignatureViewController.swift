//
//  DrawSignatureViewController.swift
//  ZipID
//
//  Created by Damien Hill on 29/02/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

protocol DrawSignatureViewDelegate {
    func cancel()
    func doneWithImage(image: UIImage?)
}

@objc class DrawSignatureViewController: UIViewController {
    
    var delegate: DrawSignatureViewDelegate?
    @IBOutlet var clearButton: UIButton?
    @IBOutlet var instructionLabel: UILabel?
    @IBOutlet var doneBarButtonItem: UIBarButtonItem?
    @IBOutlet var smoothLineView: SmoothLineView?
    @IBOutlet var divider: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        smoothLineView?.lineWidth = 4
        clearButton?.hidden = true
    }
    
    @IBAction func done() {
        let image = createImageFromSmoothLineView()
        if image != nil {
            delegate?.doneWithImage(image)
        }
    }
    
    @IBAction func cancel() {
        delegate?.cancel()
    }
    
    @IBAction func clear() {
        doneBarButtonItem?.enabled = false
        clearButton?.hidden = true
        smoothLineView?.clear()
    }
    
    @IBAction func beganDrawing(sender: AnyObject?) {
        self.doneBarButtonItem?.enabled = true
        self.clearButton?.hidden = false
    }
    
    private func createImageFromSmoothLineView() -> UIImage? {
        let boundingBox = smoothLineView?.getBoundingBox()
        if boundingBox?.size.width <= 0 || boundingBox?.size.height <= 0 {
            return nil
        }
        
        var image: UIImage?
        if let canvasSize = smoothLineView?.bounds.size,
            let size = boundingBox?.size,
            let origin = boundingBox?.origin,
            opaque = smoothLineView?.opaque
        {
            self.divider?.hidden = true
            self.instructionLabel?.hidden = true
            
            let SIGNATURE_PADDING: CGFloat = 20 * UIScreen.mainScreen().scale

            var width = size.width + (SIGNATURE_PADDING * 2)
            var height = size.height + (SIGNATURE_PADDING * 2)
            var offsetX = (origin.x - SIGNATURE_PADDING) * -1
            var offsetY = (origin.y - SIGNATURE_PADDING) * -1
   
            offsetX = offsetX < 0 ? offsetX : 0
            offsetY = offsetY < 0 ? offsetY : 0
            
            if ((offsetX * -1) + width) > canvasSize.width {
                width = canvasSize.width + offsetX
            }
            if ((offsetY * -1) + height) > canvasSize.height {
                height = canvasSize.height + offsetY
            }
            
            let newSize = CGSize(width: width, height: height)
            
            UIGraphicsBeginImageContextWithOptions(newSize, opaque, UIScreen.mainScreen().scale)
                CGContextTranslateCTM(UIGraphicsGetCurrentContext()!, offsetX, offsetY)
                smoothLineView!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            self.divider?.hidden = false
            self.instructionLabel?.hidden = false
        }
        return image
    }
    
}
