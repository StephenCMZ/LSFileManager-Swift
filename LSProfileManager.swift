//
//  LSProfileManager.swift
//  LSFileManager
//
//  Created by StephenChen on 16/7/7.
//  Copyright © 2016年 Lansion. All rights reserved.
//

import UIKit

/*
---- PRO_HOME
        |------ PRO_ACCOUNTS
        |          |----- FILE_ACCOUNTS
        |          |----- FILE_LASTACCOUNT
        |
        |------ PRO_ACCOUNTHOME
                   |------ PRO_INFO
                   |------ PRO_IMAGE
                   |------ PRO_AUDIO
                   |------ PRO_TEMP
                   |------ PRO_CUSTOM ...

*/

enum LSProFolderPath: String{
    case PRO_HOME = "profiles"
    case PRO_ACCOUNTS = "profiles/accounts"
    case PRO_ACCOUNTHOME = "profiles/%@"
    case PRO_CUSTOM = "profiles/%@/%@"
}

enum LSProFolder: String{
    case PRO_INFOS = "infos"
    case PRO_IMAGES = "images"
    case PRO_AUDIOS = "audios"
    case PRO_TEMP = "temp"
}

enum LSProKey: String {
    case KEY_LASTACCOUNT = "last_account"
    case KEY_LASTPSW = "last_password"
    case KEY_LASTCOVERID = "last_coverId"
    case KEY_PRONAME = "pro_name"
}

enum LSProFile: String {
    case FILE_ACCOUNTS = "profiles/accounts/accounts.plist"
    case FILE_LASTACCOUNT = "profiles/accounts/last_account.plist"
}

class LSProfileManager: NSObject {
    
    static let manager = LSProfileManager()
    var currentAccount: String?
    
    private override init() {
        if !LSFileManager.isFileExisted(LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR) {
            LSFileManager.createFolder(LSProFolderPath.PRO_HOME.rawValue, under: .DOC_DIR)
            LSFileManager.createFolder(LSProFolderPath.PRO_ACCOUNTS.rawValue, under: .DOC_DIR)
            LSFileManager.writeNSDictionary([:], toFile: LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR)
            LSFileManager.writeNSDictionary([:], toFile: LSProFile.FILE_LASTACCOUNT.rawValue, under: .DOC_DIR)
        }
    }
    
    //MARK: - about account
    
    private func getAccountFolder(folder: String, names: [String]) -> String{
        var tempFolder = folder
        for name in names {
            let range = tempFolder.rangeOfString("%@")
            if range != nil {
                tempFolder.replaceRange(range!, with: name)
            }else{
                break
            }
        }
        
        return tempFolder
    }
    
    static func loadProFile(account: String, password:String, coverId: String?) -> Bool {
        
        manager.currentAccount = account
        var accounts = LSFileManager.readNSDictionary(LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR)
        
        if (accounts == nil) || accounts![account] == nil {
            
            //add account to accounts.plist
            if accounts == nil { accounts = [:] }
            let mAccounts = accounts!.mutableCopy() as! NSMutableDictionary
            mAccounts.setValue("NO_ASSIGNED", forKey: account)
            LSFileManager.writeNSDictionary(mAccounts, toFile: LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR)
            
        }
        
        //create account's folders
        LSFileManager.createFolder(manager.getAccountFolder(LSProFolderPath.PRO_ACCOUNTHOME.rawValue, names: [account]), under: .DOC_DIR)
        LSFileManager.createFolder(manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account,LSProFolder.PRO_INFOS.rawValue]), under: .DOC_DIR)
        LSFileManager.createFolder(manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account,LSProFolder.PRO_IMAGES.rawValue]), under: .DOC_DIR)
        LSFileManager.createFolder(manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account,LSProFolder.PRO_AUDIOS.rawValue]), under: .DOC_DIR)
        LSFileManager.createFolder(manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account,LSProFolder.PRO_TEMP.rawValue]), under: .DOC_DIR)
        
        //add account to last_account.plist
        LSProfileManager.resetAccountPassword(password, coverId: coverId)
        
        return true
    }
    
    static func resetAccountPassword(password: String?, coverId: String? ) -> Bool {
        
        guard manager.currentAccount != nil else{ return false }
        let lastAccount = NSMutableDictionary.init(objects: [manager.currentAccount!, password ?? "", coverId ?? ""], forKeys: [LSProKey.KEY_LASTACCOUNT.rawValue, LSProKey.KEY_LASTPSW.rawValue, LSProKey.KEY_LASTCOVERID.rawValue])
        return LSFileManager.writeNSDictionary(lastAccount, toFile: LSProFile.FILE_LASTACCOUNT.rawValue, under: .DOC_DIR) != nil ? true : false
    }
    
    static func deleteProFile(account: String) -> Bool {
        
        let accounts = LSFileManager.readNSDictionary(LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR)
        guard accounts != nil &&  accounts![account] != nil else{ return false }
        
        let mAccounts = accounts!.mutableCopy() as! NSMutableDictionary
        mAccounts.removeObjectForKey(account)
        LSFileManager.writeNSDictionary(mAccounts, toFile: LSProFile.FILE_ACCOUNTS.rawValue, under: .DOC_DIR)
        LSFileManager.deleteFile(manager.getAccountFolder(LSProFolderPath.PRO_ACCOUNTHOME.rawValue, names: [account]), under: .DOC_DIR)
        
        return true
    }
    
    //MARK: - custom folder and custom read/write file
    
    private static func isFolderExisted(folderName: String) -> Bool {
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, folderName])
            return LSFileManager.isFileExisted(folder, under: .DOC_DIR)
        }else{
            return false
        }
    }
    
    static func createFolder(folderName: String) -> Bool{
        
        if (LSProfileManager.isFolderExisted(folderName)){
            return true
        }
        
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, folderName])
            return LSFileManager.createFolder(folder, under: .DOC_DIR)
        }else{
            return false
        }
        
    }
    
    static func deleteFolder(folderName: String) -> Bool{
        
        if (!LSProfileManager.isFolderExisted(folderName)){
            return true
        }
        
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, folderName])
            return LSFileManager.deleteFile(folder, under: .DOC_DIR)
        }else{
            return false
        }
        
    }
    
    static func save<T>(data: T, toFolder: String, forName: String, saveData: (data: T, path: String) -> Bool) -> Bool {
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, toFolder])
            if LSFileManager.isFileExisted(folder, under: .DOC_DIR) {
                return saveData(data: data, path: folder+"/"+forName)
            }
            return false
        }else{
            return false
        }
    }
    
    static func read<T>(name: String, fromFolder: String, readData: (path: String) -> T?) -> T? {
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, fromFolder])
            if LSFileManager.isFileExisted(folder, under: .DOC_DIR) {
                return readData(path: folder + "/" + name)
            }
            return nil
        }else{
            return nil
        }
    }
    
    static func delete(name: String, fromFolder: String, deleteData: (path: String) -> Bool) -> Bool{
        if let account = manager.currentAccount {
            let folder = manager.getAccountFolder(LSProFolderPath.PRO_CUSTOM.rawValue, names: [account, fromFolder])
            if LSFileManager.isFileExisted(folder, under: .DOC_DIR) {
                return deleteData(path: folder + "/" + name)
            }
            return true
        }else{
            return false
        }
    }
    
    //MARK: - read and write file
    
    static func saveInfoFile<T>(file: T, forName: String, saveFile:(file: T, path: String) -> Bool) -> Bool {
        return LSProfileManager.save(file, toFolder: LSProFolder.PRO_INFOS.rawValue, forName: forName, saveData: saveFile)
    }
    
    static func readInfoFile<T>(fileName: String, readFile: (path: String) -> T?) -> T? {
        return LSProfileManager.read(fileName, fromFolder: LSProFolder.PRO_INFOS.rawValue, readData: readFile)
    }
    
    static func deleteInfoFile(fileName: String, deleteFile: (path: String) -> Bool) -> Bool {
        return LSProfileManager.delete(fileName, fromFolder: LSProFolder.PRO_INFOS.rawValue, deleteData: deleteFile)
    }
    
    static func saveImage(image: UIImage, forName: String?) -> String? {
        
        let imageName:String = forName ?? (NSDate().description.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))!
        
        return (LSProfileManager.save(image, toFolder: LSProFolder.PRO_IMAGES.rawValue, forName: imageName) { (data, path) -> Bool in
            return LSFileManager.writeUIImage(data, toFile: path, under: .DOC_DIR) != nil ? true : false
        }) ? imageName : nil
        
    }
    
    static func readImage(name: String) -> UIImage? {
        return LSProfileManager.read(name, fromFolder: LSProFolder.PRO_IMAGES.rawValue) { (path) -> UIImage? in
            return LSFileManager.readUIImage(path, under: .DOC_DIR)
        }
    }
    
    static func deleteImage(name: String) -> Bool {
        return LSProfileManager.delete(name, fromFolder: LSProFolder.PRO_IMAGES.rawValue, deleteData: { (path) -> Bool in
            return LSFileManager.deleteFile(path, under: .DOC_DIR)
        })
    }
    
    static func saveAudio(audio: NSData, forName: String?) -> String? {
        
        let audioName:String = forName ?? (NSDate().description.dataUsingEncoding(NSUTF8StringEncoding)?.base64EncodedStringWithOptions(.Encoding64CharacterLineLength))!
        
        return (LSProfileManager.save(audio, toFolder: LSProFolder.PRO_AUDIOS.rawValue, forName: audioName) { (data, path) -> Bool in
            return LSFileManager.writeNSData(data, toFile: path, under: .DOC_DIR) != nil ? true : false
        }) ? audioName : nil
        
    }
    
    static func readAudio(name: String) -> NSData? {
       return LSProfileManager.read(name, fromFolder: LSProFolder.PRO_AUDIOS.rawValue) { (path) -> NSData? in
            return LSFileManager.readNSData(path, under: .DOC_DIR)
        }
    }
    
    static func deleteAudio(name: String) -> Bool {
        return LSProfileManager.delete(name, fromFolder: LSProFolder.PRO_AUDIOS.rawValue, deleteData: { (path) -> Bool in
            return LSFileManager.deleteFile(path, under: .DOC_DIR)
        })
    }
    
    static func saveTempFile<T>(file: T, forName: String, saveFile:(file: T, path: String) -> Bool) -> Bool {
       return LSProfileManager.save(file, toFolder: LSProFolder.PRO_TEMP.rawValue, forName: forName, saveData: saveFile)
    }
    
    static func readTempFile<T>(fileName: String, readFile: (path: String) -> T?) -> T? {
       return LSProfileManager.read(fileName, fromFolder: LSProFolder.PRO_TEMP.rawValue, readData: readFile)
    }
    
    static func deleteTempFile(name: String) -> Bool {
        return LSProfileManager.delete(name, fromFolder: LSProFolder.PRO_TEMP.rawValue, deleteData: { (path) -> Bool in
            return LSFileManager.deleteFile(path, under: .DOC_DIR)
        })
    }
    
}
