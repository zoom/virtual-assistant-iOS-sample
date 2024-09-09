//
//  ZMLiveSDKWebviewControllerSwift.swift
//  ZoomWebSDKSample
//
//  This sample code is for debugging purposes only and is provided as-is and without warranties of any kind.
//  It is meant only to be used by the direct recipient and may not be redistributed.
//  Copyright 2024 Zoom Video Communications, Inc. All rights reserved.

import Foundation
import WebKit
import UIKit
import SafariServices


let kZMCCWebKitMessageCmdKey =                 "cmd"
let kZMCCWebkitMessageValueKey =               "value"
let kZMCCWebkitMessageCmdType_OpenURL =        "openURL"

let kZMCCMessageHandlerName_Exit =             "zoomLiveSDKMessageHandler"
let kZMCCMessageHandlerName_SuportHandOff =    "support_handoff"
let kZMCCMessageHandlerName_CommonHandler =    "commonMessageHandler"

let kZCMCCMessage_ExitCmdValue =  "close_web_vc"

@objc class ZMWebviewConfigurationSwift: WKWebViewConfiguration {
    override init() {
        super.init()
        addUserScripts()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    func addUserScripts() {
        let userContentController = WKUserContentController()
        
        // Firstly, create a WKUserScript to pass default parameters for the web SDK. Developers can modify the parameters here.
        let injectScriptStr = """
        window.zoomCampaignSdkConfig = window.zoomCampaignSdkConfig || {
        language : '',
        firstName: '',
        lastName: '',
        nickName: '',
        address: '',
        company: '',
        email : '',
        phoneNumber : ''
        };
        """
        let injectScript = WKUserScript(source: injectScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(injectScript)
        
        /*
        Create an exit message handler to handle the case where the JavaScript context needs to pop to the previous page in the host app.
        Also, create a common message handler to handle commands from the JavaScript context. The command message will be a JSON formatted string containing keys "cmd" and "value". Both key values are strings. The value can be a simple string or a JSON string, depending on the command type. Currently, we support one command in JSON format like {"cmd":"openURL", "value":"https://zoom.us"}. When such a message is received, developers should open a new view controller to load the URL in the value "https://zoom.us". The demo code shows several ways to process the message in the WKWebView delegate method: - (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message.
         */
        let exitHandlerScriptStr = """
        window.addEventListener('zoomCampaignSdk:ready', () => {
          if (window.zoomCampaignSdk) {
            window.zoomCampaignSdk.native = {
              exitHandler: {
                handle: function() {
                  window.webkit.messageHandlers.zoomLiveSDKMessageHandler.postMessage('close_web_vc');
                }
              },
              commonHandler: {
                handle: function(e) {
                  window.webkit.messageHandlers.commonMessageHandler.postMessage(JSON.stringify(e));
                }
              }
            }
          }
        })
        """
        let exitScript = WKUserScript(source: exitHandlerScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(exitScript)
        
        // This WKUserScript creates a message handler called "support_handoff" to handle messages from the JavaScript context that should be handled by the host app.
        let supportHandoffScriptStr = """
        window.addEventListener('support_handoff', (e) => {
          window.webkit.messageHandlers.support_handoff.postMessage(JSON.stringify(e.detail));
        });
        """
        let supportHandoffScript = WKUserScript(source: supportHandoffScriptStr, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(supportHandoffScript)
        
        self.userContentController = userContentController
    }
    
    func messageHandlerNames() -> [String] {
        return [kZMCCMessageHandlerName_Exit, kZMCCMessageHandlerName_SuportHandOff, kZMCCMessageHandlerName_CommonHandler]
    }
}


@objc class ZMLiveSDKWebviewControllerSwift: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, WKDownloadDelegate {
    private var url: String
    private var config: ZMWebviewConfigurationSwift
    var localFileDownloadURL: URL?
    
    /*!
     @brief Indicates whether to open URLs received from the JavaScript handler "commonMessageHandler" in the system browser. YES to open in the system browser, NO to open within a new view controller in the app. Default is YES.
     */
    var openURLInSystemBrowser: Bool

    
    lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        return webView
    }()
    
    @objc public init(url: String, config: ZMWebviewConfigurationSwift) {
        self.url = url
        self.config = config
        self.openURLInSystemBrowser = true;
        super.init(nibName: nil, bundle: nil)
        configWebViewMessageHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configWebViewMessageHandlers() {
        for messageHandlerName in config.messageHandlerNames() {
            config.userContentController.add(self, name: messageHandlerName)
        }
    }
    
    func removeWebViewMessageHandlers() {
        for messageHandlerName in self.config.messageHandlerNames() {
            self.config.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
        }
    }

    
    deinit {
        print("ZMLiveSDKWebviewController dealloc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(webView)
        addNavigationBar();
        loadURL()
    }
    
    func addNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 40, width: self.view.bounds.size.width, height: self.navigationController?.navigationBar.bounds.size.height ?? 44))
        let navItem = UINavigationItem(title: "")
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleGoBack))
        navItem.leftBarButtonItem = backButton
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
        self.view.bringSubviewToFront(navBar)
    }

    @objc func handleGoBack() {
        if webView.canGoBack {
            webView.goBack()
        }
        else {
            weak var weakSelf = self
            let alert = UIAlertController(title: nil, message: "Leave Current Page?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .destructive) { action in
                weakSelf?.removeWebViewMessageHandlers()
                weakSelf?.navigationController?.popViewController(animated: true)
            })
            self.navigationController?.present(alert, animated: true, completion: nil)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if #available(iOS 13.0, *) {
            UIApplication.shared.statusBarStyle = .darkContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = CGRect(x: 0, y:84, width: view.frame.size.width, height: view.bounds.size.height - 84)
    }
    
    private func loadURL() {
        if let targetURL = URL(string: url) {
            webView.load(URLRequest(url: targetURL))
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        // Handle the current webview controller's pop action
        if message.name == kZMCCMessageHandlerName_Exit {
            if let body = message.body as? String, body == kZCMCCMessage_ExitCmdValue {
                self.removeWebViewMessageHandlers()
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        // Handle the openURL command. Developers should open a new UIViewController to load the URL within the value, or open the URL in Safari.
        else if message.name == kZMCCMessageHandlerName_CommonHandler {
            if let body = message.body as? String, !body.isEmpty {
                if let data = body.data(using: .utf8) {
                    do {
                        if let dic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                            if let cmd = dic[kZMCCWebKitMessageCmdKey] as? String, cmd == kZMCCWebkitMessageCmdType_OpenURL {
                                // Choose to open the URL with the system default web browser (Safari)
                                if let urlString = dic[kZMCCWebkitMessageValueKey] as? String, let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)), UIApplication.shared.canOpenURL(url) {
                                    
                                    if (self.openURLInSystemBrowser) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                    else {
                                        
                                        // Or use SFSafariViewController to open the URL
                                        let safariVC = SFSafariViewController(url: url)
                                        self.navigationController?.present(safariVC, animated: true, completion: nil)
                                        
                                        // Or just open it with another webview like below
                                        /*
                                        let config = ZMWebviewConfiguration()
                                        let vc = ZMLiveSDKWebviewController(url: url, webviewConfiguration: config)
                                        self.navigationController?.pushViewController(vc, animated: true)
                                         */
                                    }
                                }
                            }
                        }
                    } catch {
                        print("JSON parsing error: \(error)")
                    }
                }
            }
        }
        else if message.name == kZMCCMessageHandlerName_SuportHandOff {
            // Handle the support_handoff command. For this event, the JavaScript context will archive all the messages into a JSON string, and post the JSON string to native logic via message.body. Developers should handle the JSON string as needed.
            print(message.body)
        }
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Handle web view did finish navigation
    }
    
    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        // Set the download delegate to receive callbacks when the download is finished.
        download.delegate = self
    }
    
    //When logic "windown.open" excuted in js context, this callback will be recevied.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                let options: [UIApplication.OpenExternalURLOptionsKey: Any] = [.universalLinksOnly: false]
                UIApplication.shared.open(url, options: options, completionHandler: nil)
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // The download action only supports iOS 14.5+.
        if #available(iOS 14.5, *) {
            if navigationAction.shouldPerformDownload {
                decisionHandler(.download)
                return
            }
        }
        
        // Developers can choose to process the navigation by the URL. For example, if the URL is https://zoom.us, developers can choose to open it in Safari or handle it in the current WKWebView by calling the block "decisionHandler(WKNavigationActionPolicyAllow)". This depends on the developer's requirements.
        if navigationAction.navigationType == .linkActivated {
            if let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame {
                decisionHandler(.allow)
            } 
            else {
                if let url = navigationAction.request.url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10.0, *) {
                        let openUrlOptions:[UIApplication.OpenExternalURLOptionsKey:Any] = [.universalLinksOnly:false]
                        UIApplication.shared.open(url, options: openUrlOptions, completionHandler: nil)
                    }
                    else {
                        let safariVC = SFSafariViewController(url:url)
                        self.navigationController?.pushViewController(safariVC, animated: true)
                    }
                }
                decisionHandler(.cancel)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
       // MARK: - WKDownloadDelegate

    @available(iOS 14.5, *)
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        // Create a local file download directory and the file path in that directory.
        let tmpDir = NSTemporaryDirectory()
        let uuidStr = UUID().uuidString
        let tmpDirURL = URL(fileURLWithPath: tmpDir)
        let tmpUUIDURL = tmpDirURL.appendingPathComponent(uuidStr)
        do {
            try FileManager.default.createDirectory(at: tmpUUIDURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print("Creating directory failed: \(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        self.localFileDownloadURL = tmpUUIDURL.appendingPathComponent(suggestedFilename)
        completionHandler(self.localFileDownloadURL)
       }
       
    @available(iOS 14.5, *)
    func downloadDidFinish(_ download: WKDownload) {
        DispatchQueue.main.async {
            // When the file is downloaded, use the UIActivityViewController to open it for the next step usage.
            guard let localFileDownloadURL = self.localFileDownloadURL else {
                return
            }
            
            let activityVC = UIActivityViewController(activityItems: [localFileDownloadURL], applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = self.view
            activityVC.popoverPresentationController?.sourceRect = self.view.frame
            activityVC.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(activityVC, animated: true, completion: nil)
        }
    }
       
    @available(iOS 14.5, *)
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        print("WKWebView download failed: \(error.localizedDescription)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}


