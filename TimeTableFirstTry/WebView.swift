//
//  WebView.swift
//  TimeTableFirstTry
//
//  Created by Aurel Feer on 20.11.15.
//  Copyright © 2015 Aurel Feer. All rights reserved.
//

import UIKit

class WebView: UIViewController {
    
    //OUTLETS
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let URLforRequest = NSURL(string: "https://oauth.tam.ch/signin/klw-stupla-app?response_type=token&client_id=0Wv69s7vyidj3cKzNckhiSulA5on8uFM&redirect_uri=uniapp%3A%2F%2Fklw-stupla-app&_blank&scope=all")
        let request = NSURLRequest(URL: URLforRequest!)
        
        webView.loadRequest(request)
    }
    
}
