//
//  WelcomeViewControllerExtensions.swift
//  MemoryBooth
//
//  Created by Wayne Rumble on 25/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit

extension WelcomeScreenViewController {
    
    func startDownload() {
        
        let url = URL(string: "http://waynerumble.local:4567/download") //FIXME change to memorybooth.local
        downloadTask = backgroundSession.downloadTask(with: url!)
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        
        let documentsUrl: URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let filePath = documentsUrl.appendingPathComponent("Images.zip")
        let fileManager = FileManager()
        

        do {
            try fileManager.moveItem(at: location, to: filePath)

        } catch {
            print("An error occurred while moving file to destination url")
        }
    }
    // 2
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        downloadTask = nil
        progressView.setProgress(0.0, animated: true)
        
        if (error != nil) {
            
            print(error!.localizedDescription)
        } else {
            
            startUnzippingFile()
            print("The task finished transferring data successfully")
        }
    }
}
