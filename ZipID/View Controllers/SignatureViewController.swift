//
//  SignatureViewController.swift
//  ZipID
//
//  Created by Damien Hill on 29/02/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import Mustache
import SafariServices

@objc class SignatureViewController: ZPQuestionViewController, DrawSignatureViewDelegate, UIWebViewDelegate {

    var selectedImageReference: String?
    @IBOutlet var clearButton: UIButton?
    @IBOutlet var signButton: UIButton?
    @IBOutlet var previewImage: UIImageView?
    @IBOutlet var webView: UIWebView?
    var question: ZPQuestion?
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        clearButton?.enabled = false
        clearButton?.hidden = true
        
        if let question = self.job.questions?[NSInteger(questionIndex)] as? ZPQuestion {
            self.question = question
            
            var templateContent: String
            if question.detailText != nil {
                templateContent = question.detailText
            } else if question.question != nil {
                templateContent = question.question
            } else {
                templateContent = ""
            }
            
            let questionContent = renderMustache(templateContent)
            let htmlContent = renderMarkdown(questionContent)
            renderWebView(htmlContent)
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if (parent == nil) {
            if let imageReference = self.selectedImageReference {
                let imageManager = ImageManager()
                imageManager.removeImage(imageReference)
            }
        }
        super.didMoveToParentViewController(parent)
    }
    
    // MARK: Render
    private func renderMustache(templateContent: String) -> String {
        let templateModel = self.job.dictionaryForMergeFields() as! Dictionary<String, AnyObject>
        let rendered: String
        do {
            let template = try Template(string: templateContent)
            rendered = try template.render(Box(templateModel))
        } catch _ {
            rendered = ""
        }
        return rendered
    }
    
    private func renderMarkdown(questionContent: String) -> String {
        var markdown = Markdown()
        let rendered = markdown.transform(questionContent)
        if let fileURL = NSBundle.mainBundle().URLForResource("WebView Assets/templates/main", withExtension: "html") {
            let htmlContent: String
            do {
                htmlContent = try String(contentsOfURL: fileURL)
            } catch {
                htmlContent = ""
            }
            return htmlContent.stringByReplacingOccurrencesOfString("{{{body}}}", withString:rendered)
        } else {
            return ""
        }
    }
    
    private func renderWebView(htmlContent: String) {
        let baseURL = NSBundle.mainBundle().URLForResource("WebView Assets", withExtension: nil)
        self.webView?.loadHTMLString(htmlContent, baseURL: baseURL)
    }

    // MARK: UI actions
    @IBAction func editSignature(sender: AnyObject?) {
        let navVC = self.getView("DrawSignature", forStoryboard: "Questions", universal: true)
        if let drawVC:DrawSignatureViewController = navVC.childViewControllers.last as? DrawSignatureViewController {
            drawVC.delegate = self
            drawVC.title = self.title
            self.presentViewController(navVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func clearImage(sender: AnyObject?) {
        if let imageReference = self.selectedImageReference {
            let imageManager = ImageManager()
            imageManager.removeImage(imageReference)
        }
        previewImage?.image = nil
        selectedImageReference = nil
        clearButton?.enabled = false
        clearButton?.hidden = true
        self.hasResponse = false
    }
    
    private func loadPreviewImage() {
        let imageManager = ImageManager()
        previewImage?.image = imageManager.getImage(self.selectedImageReference!)
    }
    
    // MARK: QuestionViewController subclass
    override func saveToResponse() {
        let questionIndex = Int(self.questionIndex)
        if let question = self.job.questions?[questionIndex] as? ZPQuestion {
            let imageResponse = ZPImageResponse()
            imageResponse.documentId = question.documentId
            imageResponse.questionIndex = self.questionIndex
            imageResponse.imageReference = selectedImageReference
            imageResponse.documentType = question.documentType
            imageResponse.documentName = question.title
            
            if question.detailText != nil {
                imageResponse.text = renderMustache(question.detailText)
            }
            
            if question.documentType == "clientSignature" {
                self.surveyResponse.clientSignature = imageResponse
            } else if question.documentType == "agentSignature" {
                self.surveyResponse.agentSignature = imageResponse
            }
        }
        super.saveToResponse()
    }
    
    override func removeFromResponse() {
        let questionIndex = Int(self.questionIndex)
        if let question = self.job.questions?[questionIndex] as? ZPQuestion {
            if question.documentType == "clientSignature" {
                self.surveyResponse.clientSignature = nil
            } else if question.documentType == "agentSignature" {
                self.surveyResponse.agentSignature = nil
            }
        }
        super.removeFromResponse()
    }
    
    // MARK: DrawSignatureViewDelegate
    func doneWithImage(image: UIImage?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if let newImage = image {
            let imageManager = ImageManager()
            if let oldImageReference = self.selectedImageReference {
                imageManager.removeImage(oldImageReference)
            }
            if let imageReference = imageManager.storeImage(newImage) {
                self.selectedImageReference = imageReference
                self.clearButton?.enabled = true
                self.clearButton?.hidden = false
                self.hasResponse = true                
                self.loadPreviewImage()
            }
        }
    }
    
    func cancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIWebViewDelegate
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .Other {
            return true
        } else {
            if let URL = request.URL {
                if #available(iOS 9.0, *) {
                    let safari = SFSafariViewController(URL: URL)
                    self.presentViewController(safari, animated: true, completion: nil)
                } else {
                    UIApplication.sharedApplication().openURL(URL)
                }
            }
            return false
        }
    }    

}
