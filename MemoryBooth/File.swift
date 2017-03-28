//
//  Unzipper.swift
//  MemoryBooth
//
//  Created by Wayne Rumble on 23/03/2017.
//  Copyright © 2017 Wayne Rumble. All rights reserved.
//

import UIKit
import SSZipArchive

class File {
        
    var fileManager: FileManager!
    var documentsURL: URL?
    
    init() {
        
        setVariables()
        deleteOldFiles()
    }
    
    func setVariables() {
        
        fileManager = FileManager.default
        documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func returnImageURLs() -> [URL] {
        
        var directoryContents = [URL]()
        
        do {
            // Get the directory contents urls (including subfolders urls)
            directoryContents = try fileManager.contentsOfDirectory(at: documentsURL!, includingPropertiesForKeys: nil, options: [])
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
        
        let images = directoryContents.filter{ $0.pathExtension == "jpg" }//FIXME change file types if needed
        
        return images
    }
    
    func unZip(finished: @escaping ()->()) {
        
        
        let zipFileURL = documentsURL?.appendingPathComponent("Images.zip")//FIXME change name of saved file
        
        SSZipArchive.unzipFile(atPath: (zipFileURL?.path)!, toDestination: (documentsURL?.path)!)
        
        finished()
    }
    
    private func deleteOldFiles() {
        
        let documentsPath = documentsURL?.path
        
        do {
            
            if let documentPath = documentsPath {
                
                let fileNames = try fileManager.contentsOfDirectory(atPath: "\(documentPath)")
                
                for fileName in fileNames {
                    
                    try fileManager.removeItem(atPath: "\(documentPath)/\(fileName)")
                }
            } else {
                
            }
        } catch {
            
            print("Could not clear documents folder: \(error)")
        }
    }
}
