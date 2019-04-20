//
//  InfinteCampusController.swift
//  Conant Map
//
//  Created by Johnny Waity on 9/21/18.
//  Copyright © 2018 Johnny Waity. All rights reserved.
//

import UIKit
import WebKit

class InfinteCampusController: UIViewController, WKNavigationDelegate {
    
    let username:String
    let password:String
    
    let completion:(String?, String?) -> Void
    
    var javascriptInject = ""
    
    var attemptedLogin = false
    
    init(firstName:String, lastName:String, birthday:Date, id:String, completionHandler: @escaping (_ result:String?, _ error:String?) -> Void) {
        var usernameEntry = id
        if usernameEntry.count == 6 {
            usernameEntry = "000" + usernameEntry
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.setLocalizedDateFormatFromTemplate("MMddyy")
        var dateString = dateFormatter.string(from: birthday)
        dateString = dateString.replacingOccurrences(of: "/", with: "")
        
        password = "'\(firstName.lowercased().first!)\(lastName.lowercased().first!)" + dateString + "'"
        
        username = "'\(usernameEntry)'"
        
        completion = completionHandler
        
        super.init(nibName: nil, bundle: nil)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webView = WKWebView()
        webView.navigationDelegate = self
        let req = URLRequest(url: URL(string: "https://campus.d211.org/campus/portal/township.jsp")!)
        webView.load(req)
        view = webView
        do{
            javascriptInject = try String(contentsOfFile: Bundle.main.path(forResource: "IC", ofType: "js")!)
        }catch{
            print(error)
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Navigated to: " + (webView.url?.absoluteString)!)
        
        switch webView.url?.absoluteString {
        case "https://campus.d211.org/campus/portal/township.jsp":
            if attemptedLogin {
                self.completion(nil, "Login Failed Check Information Entered")
                return
            }
            self.attemptedLogin = true
            webView.evaluateJavaScript("document.getElementById('username').value = " + username, completionHandler: nil)
            webView.evaluateJavaScript("document.getElementById('password').value = " + password, completionHandler: nil)
            webView.evaluateJavaScript("document.getElementById('signinbtn').click()", completionHandler: nil)
            break
        default:
            if (webView.url?.absoluteString.contains("main.xsl"))! {
                webView.evaluateJavaScript("document.getElementById('frameDetail').contentWindow.document.getElementById('schedule').click()", completionHandler: nil)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    webView.evaluateJavaScript(self.javascriptInject + "getTable();", completionHandler: { (res, error) in
                        if let sch = res as? String {
                            self.completion(sch, nil)
                        }
                    })
                }
                
            }else if(webView.url?.absoluteString.contains("township.jsp"))!{
                if attemptedLogin {
                    self.completion(nil, "Login Failed Check Information Entered")
                    return
                }
            }
            break
        }
    }
    

}
