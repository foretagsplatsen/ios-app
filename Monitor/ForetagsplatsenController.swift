//
//  ForetagsplatsenController.swift
//  Monitor
//
//  Created by Benjamin Van Ryseghem on 2015-11-24.
//  Copyright (c) 2015 Företagsplatsen AB. All rights reserved.
//

import WebKit
import UIKit

class ForetagsplatsenController: UIViewController, UIWebViewDelegate {
    
    static var webView: WKWebView?
    static let baseUrl: String = "https://staging-gt-test.foretagsplatsen.se/"

    @IBOutlet weak var menuButton:UIBarButtonItem!
    
    let ftgpUrl = ForetagsplatsenController.baseUrl + "Accounting2/Company/a-gttest-123456-1112"
    
    let toggleActionsJs = "window.ftgp.toggleActions();"
    
    override func loadView() {
        super.loadView()
        setupWebView()
        
        let label = UILabel()
        label.frame = ForetagsplatsenController.webView!.bounds
        label.text = "Loading"
        label.textAlignment = NSTextAlignment.Center;
        ForetagsplatsenController.webView?.addSubview(label)
        
        self.view = ForetagsplatsenController.webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.revealViewController().rearViewRevealWidth = 240
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: ftgpUrl)!)
        
        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = cookieStorage.cookies! as [NSHTTPCookie]
        let values = NSHTTPCookie.requestHeaderFieldsWithCookies(cookies)
        request.allHTTPHeaderFields = values
        
        request.addValue("true", forHTTPHeaderField: "mobile-integration")
        
        ForetagsplatsenController.webView!.loadRequest(request)
    }
    
    func toggleRightMenu() {
        ForetagsplatsenController.webView!.evaluateJavaScript(toggleActionsJs){
            (_:AnyObject?, _:NSError?) in
        }
    }
    
    func setupWebView() {
        let userContentController = WKUserContentController()
        if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
            let script = getJSCookiesString(cookies)
            let cookieScript = WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: false)
            userContentController.addUserScript(cookieScript)
        }
        let webViewConfig = WKWebViewConfiguration()
        
        addHandlers(userContentController)
        webViewConfig.userContentController = userContentController
        
        ForetagsplatsenController.webView = WKWebView(frame: self.view.bounds, configuration: webViewConfig)
    }
    
    ///Generates script to create given cookies
    func getJSCookiesString(cookies: [NSHTTPCookie]) -> String {
        var result = ""
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.stringFromDate(date)); "
            }
            if (cookie.secure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }
    
    func addHandlers(userContentController: WKUserContentController) {
        class LoadedScriptMessageHandler: NSObject, WKScriptMessageHandler {
            @objc func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
                if(message.body["loaded"] as! Bool) {
                    
                    for view in ForetagsplatsenController.webView!.subviews {
                        if view.isKindOfClass(UILabel) {
                            view.removeFromSuperview()
                        }
                    }
                    
                    ForetagsplatsenController.webView?.opaque = true
                    
                    let view = ForetagsplatsenController.webView!
                    view.evaluateJavaScript("JSON.stringify(window.ftgp.getNavigation());"){
                        (ret:AnyObject?, _:NSError?) in
                            let jsonString = ret as! String
                            let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                            MenuController.setData(JSON(data: dataFromString!))
                    }
                    
                    
                } else {
                    // Should never happend
                    print("false")
                }
            }
        }
        
        class MenuUpdatedScriptMessageHandler: NSObject, WKScriptMessageHandler {
            @objc func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
                if(message.body["menuUpdated"] as! Bool) {
                    
                    let view = ForetagsplatsenController.webView!
                    view.evaluateJavaScript("JSON.stringify(window.ftgp.getNavigation());"){
                        (ret:AnyObject?, _:NSError?) in
                        let jsonString = ret as! String
                        let dataFromString = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                        MenuController.setData(JSON(data: dataFromString!))
                    }
                    
                } else {
                    // Should never happend
                    print("false")
                }
            }
        }
        
        let handler = LoadedScriptMessageHandler()
        userContentController.addScriptMessageHandler(handler, name: "loaded")
        
        let menuHandler = MenuUpdatedScriptMessageHandler()
        userContentController.addScriptMessageHandler(menuHandler, name: "menuUpdated")
    }
}


