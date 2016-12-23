//
//  HelpViewController.swift
//  ZipID
//
//  Created by Damien Hill on 9/06/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation

class HelpViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet var webView: UIWebView?
    let baseURL: String
    
    required init?(coder aDecoder: NSCoder) {
    #if DEV
        baseURL = "https://localhost:3001"
        #else
        baseURL = "https://zipid.com.au"
        #endif
        super.init(coder: aDecoder)
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let URL = NSURL(string: "\(baseURL)/app-content/help") {
            webView?.loadRequest(NSURLRequest(URL: URL))
        }
    }
    
}