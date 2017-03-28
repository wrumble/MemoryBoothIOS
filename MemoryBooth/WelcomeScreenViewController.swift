//
//  ViewController.swift
//  MemoryBooth
//
//  Created by Wayne Rumble on 23/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration.CaptiveNetwork

class WelcomeScreenViewController: UIViewController, URLSessionDownloadDelegate  {

    let file = File()
    //let downloader = Downloader()
    
    var wiFiSsid = "No Network Yet"
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var reachability: Reachability!
        
    @IBOutlet weak var wiFiTextView: UITextView!
    @IBOutlet weak var copyPasswordButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityIndicatorLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSessionVariables()
        hideActivityViews()
        getWiFiSsid()
        checkInitialWiFi()
        //correctWiFiFound() //FIXME delete this line for production
        setTextView()
        setButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setTextViewConstraints()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! PhotoCollectionViewController
        destinationVC.imagesURLArray = file.returnImageURLs()
    }
    
    func setSessionVariables() {
        
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: .main)
        progressView.setProgress(0.0, animated: false)
    }
    
    func hideActivityViews() {
        
        activityIndicatorLabel.isHidden = true
        activityIndicatorLabel.text = "Downloading Photos..."
        activityIndicator.isHidden = true
        progressView.isHidden = true
    }
    
    func checkInitialWiFi() {
        
        if wiFiSsid == "BTHub5-396S" { //FIXME change to memorybooth
            
            correctWiFiFound()
        } else {
            
            addWiFiNotification()
        }
    }
    
    @IBAction func copyPasswordButtonWasPressed(_ sender: Any) {
        
        UIPasteboard.general.string = "m3m0ryb00th"
    }
    
    func addWiFiNotification() {
        
        //Network Reachability Notification check
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: ReachabilityChangedNotification, object: nil)
        
        self.reachability = Reachability.init()
        
        do {
            try self.reachability.startNotifier()
        } catch {
            
        }
    }
    
    func setButton() {
        
        copyPasswordButton.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    }
    
    func setTextView() {
        
        wiFiTextView.text = "Please change your wifi connection to 'memorybooth' so you can download your photos.The password is\nm3m0ryb00th"
        wiFiTextView.sizeToFit()
        wiFiTextView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
    }
    
    func setTextViewConstraints() {
        
        let contentSize = self.wiFiTextView.sizeThatFits(self.wiFiTextView.bounds.size)
        var frame = self.wiFiTextView.frame
        
        frame.size.height = contentSize.height
        
        self.wiFiTextView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: self.wiFiTextView, attribute: .height, relatedBy: .equal, toItem: self.wiFiTextView, attribute: .width, multiplier: wiFiTextView.bounds.height/wiFiTextView.bounds.width, constant: 1)
        
        self.wiFiTextView.addConstraint(aspectRatioTextViewConstraint)
    }
    
    func getWiFiSsid() {
        
        var ssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            
            for interface in interfaces {
                
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        
        if ssid != nil {
            
            wiFiSsid = ssid!
        } else {
            
            wiFiSsid = "No WiFi Connection"
        }
    }
    
    func correctWiFiFound() {
        
        showOrHideViews()
        activityIndicator.startAnimating()
        startDownload()
    }
    
    func startUnzippingFile() {
        
        activityIndicatorLabel.text = "Unzipping Photos..."
        self.file.unZip {
            
            DispatchQueue.main.async {
                [weak self] in
                
                self?.performSegue(withIdentifier: "segueToPhotoCollectionViewController", sender: self)
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    func showOrHideViews() {
        
        activityIndicatorLabel.isHidden = false
        activityIndicator.isHidden = false
        progressView.isHidden = false
        copyPasswordButton.isHidden = true
        wiFiTextView.isHidden = true
    }
    
//MARK:- Network Check
    func reachabilityChanged(notification: Notification) {
        
        getWiFiSsid()
        
        if wiFiSsid == "BTHub5-396S" { //FIXME change to memorybooth
            
            let reachability = notification.object as! Reachability
            
            correctWiFiFound()
            
            reachability.stopNotifier()
        }
    }
}

