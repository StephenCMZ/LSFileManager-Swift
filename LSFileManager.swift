//
//  LSFileManager.swift
//  LSFileManager
//
//  Created by StephenChen on 16/7/7.
//  Copyright © 2016年 Lansion. All rights reserved.
//

import UIKit
import Foundation

enum LSDirectory {
    case HOME_DIR
    case DOC_DIR
    case CACHE_DIR
    case LIB_DIR
    case TMP_DIR
}

class LSFileManager: NSObject {
    
    private override init() {}
    static let manager = LSFileManager()
    let fileManager = NSFileManager.defaultManager()
    
    //MARK: -  about directory
    
    let homeDir = NSHomeDirectory()
    let docDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    let cacheDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    let libDir = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    let tempDir = NSTemporaryDirectory()
    
    static func printDirs(){
        print("home = \(manager.homeDir)")
        print("docDir = \(manager.docDir)")
        print("cacheDir = \(manager.cacheDir)")
        print("libDir = \(manager.libDir)")
        print("tempDir = \(manager.tempDir)")
    }
    
    static func getDir(dir: LSDirectory) -> String {
        switch dir {
        case LSDirectory.HOME_DIR:
            return manager.homeDir
        case LSDirectory.DOC_DIR:
            return manager.docDir
        case LSDirectory.CACHE_DIR:
            return manager.cacheDir
        case LSDirectory.LIB_DIR:
            return manager.libDir
        case LSDirectory.TMP_DIR:
            return manager.tempDir
        }
    }
    
    //MARK: - about folder
    
    static func listFolder(dir: LSDirectory, path: String?) -> [String]? {
        return manager.fileManager.subpathsAtPath(manager.getFullPath(dir,path: path))
    }
    
    static func createFolder(folderName: String, under: LSDirectory) -> Bool {
        do{
            try manager.fileManager.createDirectoryAtPath(manager.getFullPath(under,path: folderName), withIntermediateDirectories: true, attributes: nil)
            return true
        } catch{
            return false
        }
    }
    
    static func deleteFile(filePath: String, under: LSDirectory) -> Bool {
        do {
            try manager.fileManager.removeItemAtPath(manager.getFullPath(under,path: filePath))
            return true
        } catch {
            return false
        }
    }
    
    static func isFileExisted(filePath: String, under: LSDirectory) -> Bool {
        return manager.fileManager.fileExistsAtPath(manager.getFullPath(under,path: filePath))
    }
    
    //MARK: - read and write
    
    private func getFullPath(dir: LSDirectory, path: String?) -> String{
        return (path != nil) ? LSFileManager.getDir(dir) + "/" + path! : LSFileManager.getDir(dir)
    }
    
    static func writeNSData(data: NSData, toFile: String, under: LSDirectory) -> String? {
        let path = manager.getFullPath(under,path: toFile)
        let isWrite = data.writeToFile(path, atomically: true)
        return isWrite ? path : nil
    }
    static func readNSData(fromFile: String, under: LSDirectory) -> NSData? {
        return NSData.init(contentsOfFile: manager.getFullPath(under,path: fromFile))
    }
    
    static func writeNSArray(array: NSArray, toFile: String, under: LSDirectory) -> String? {
        let path = manager.getFullPath(under,path: toFile)
        let isWrite = array.writeToFile(path, atomically: true)
        return isWrite ? path : nil
    }
    static func readNSArray(fromFile: String, under: LSDirectory) -> NSArray? {
        return NSArray.init(contentsOfFile: manager.getFullPath(under, path: fromFile))
    }
    
    static func writeNSDictionary(dictionary: NSDictionary, toFile: String, under: LSDirectory) -> String? {
        let path = manager.getFullPath(under, path: toFile)
        let isWrite = dictionary.writeToFile(path, atomically: true)
        return isWrite ? path : nil
    }
    static func readNSDictionary(fromFile: String, under: LSDirectory) -> NSDictionary? {
        return NSDictionary.init(contentsOfFile: manager.getFullPath(under, path: fromFile))
    }
    
    static func writeUIImage(image: UIImage, toFile: String, under: LSDirectory) -> String? {
        let imgData = UIImagePNGRepresentation(image)
        return (imgData != nil) ? LSFileManager.writeNSData(imgData!, toFile: toFile, under: under) : nil
    }
    static func readUIImage(fromFile: String, under: LSDirectory) -> UIImage? {
        let imgData = LSFileManager.readNSData(fromFile, under: under)
        return (imgData != nil) ? UIImage.init(data: imgData!) : nil
    }
    
}
