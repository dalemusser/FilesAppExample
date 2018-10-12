//
//  FilesViewController.swift
//  FilesAppExample
//
//  Created by Dale Musser on 4/23/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//
// https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder
// https://stackoverflow.com/questions/28268145/get-file-size-in-swift
// https://medium.com/ios-os-x-development/icloud-drive-documents-1a46b5706fe1
// https://medium.com/ios-os-x-development/enable-slide-to-delete-in-uitableview-9311653dfe2
// https://developer.apple.com/library/content/documentation/General/Conceptual/iCloudDesignGuide/Chapters/DesigningForDocumentsIniCloud.html#//apple_ref/doc/uid/TP40012094-CH2-SW20
// https://www.appcoda.com/dropbox-api-tutorial/
// https://stackoverflow.com/questions/30763153/upload-files-to-dropbox-from-ios-app-with-swift
// https://www.spaceotechnologies.com/ios-tutorial-import-dropbox-photos-dropbox-api-integration/

// https://www.raywenderlich.com/147086/alamofire-tutorial-getting-started-2
// https://robots.thoughtbot.com/using-the-dropbox-objectivec-api-in-swift

// https://github.com/dropbox/SwiftyDropbox

// https://github.com/box/box-ios-sdk

// https://github.com/OneDrive/onedrive-sample-sync-ios
// https://docs.microsoft.com/en-us/onedrive/developer/sample-code
// https://github.com/OneDrive/onedrive-sdk-ios

// https://reallifeprogramming.com/carthage-vs-cocoapods-vs-git-submodules-9dc341ec6710

// https://www.bignerdranch.com/blog/working-with-the-files-app-in-ios-11/

// https://developer.apple.com/documentation/fileprovider

// https://developer.apple.com/documentation/uikit/uidocumentbrowserviewcontroller

// https://medium.com/@ashwin.kanjariya/browse-documents-in-ios-f86b86d2a350

// https://github.com/thesecretlab/Swift-4-Workshop/blob/master/Document/Document/DocumentBrowserViewController.swift

// https://dropbox.github.io/SwiftyDropbox/api-docs/latest/index.html#manually-add-subproject

// https://github.com/Alamofire/Alamofire

import UIKit

class FilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sourceSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var documentFiles = [File]()
    var iCloudFiles = [File]()
    var dropBoxFiles = [File]()
    var boxFiles = [File]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Files"

    }
    
    override func viewDidAppear(_ animated: Bool) {
        switch getCurrentSource() {
        case "Documents":
            documentFiles = getDocumentFiles()
        case "iCloud":
            iCloudFiles = getiCloudFiles()
        case "DropBox":
            dropBoxFiles = getDropBoxFiles()
        case "Box":
            boxFiles = getBoxFiles()
        default:
            documentFiles = getDocumentFiles()
        }
        
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getCurrentSource() -> String {
        let choiceIndex = sourceSegmentedControl.selectedSegmentIndex
        if let choiceTitle = sourceSegmentedControl.titleForSegment(at: choiceIndex) {
            return choiceTitle
        } else {
            return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch getCurrentSource() {
        case "Documents":
            return documentFiles.count
        case "iCloud":
            return iCloudFiles.count
        case "DropBox":
            return dropBoxFiles.count
        case "Box":
            return boxFiles.count
        default:
            return documentFiles.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        
        let source = getCurrentSource()
        
        var files = [File]()
        switch source {
        case "Documents":
            files = documentFiles
        case "iCloud":
            files = iCloudFiles
        case "DropBox":
            files = dropBoxFiles
        case "Box":
            files = boxFiles
        default:
            files = documentFiles
        }
        
        let file = files[indexPath.row]
        cell.textLabel?.text = file.name
        cell.detailTextLabel?.text = "\(file.size) bytes stored in \(source)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            //self.tableArray.remove(at: indexPath.row)
            
            switch self.getCurrentSource() {
            case "Documents":
                self.deleteDocumentFile(index: indexPath.row)
            case "iCloud":
                self.deleteiCloudFile(index: indexPath.row)
            case "DropBox":
                self.deleteDropBoxFile(index: indexPath.row)
            case "Box":
                self.deleteBoxFile(index: indexPath.row)
            default:
                self.deleteDocumentFile(index: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return [delete]
    }
    
    
    func getDocumentFiles() -> [File] {
        var files = [File]()
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                let fileName = fileURL.lastPathComponent
                files.append(File(url: fileURL, name: fileName, size: fileSize))
            }
        } catch {
            print("Error while enumerating files \(documentsURL.path): \(error.localizedDescription)")
        }
        
        return files
    }
    
    func deleteDocumentFile(index: Int) {
        let file = documentFiles[index]
        self.documentFiles.remove(at: index)
        try? FileManager.default.removeItem(at: file.url)
    }
    
    func getiCloudFiles() -> [File] {
        var files = [File]()
        
        let fileManager = FileManager.default

        guard let iCloudDocumentsURL = fileManager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            return files
        }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: iCloudDocumentsURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                let fileSize = attr[FileAttributeKey.size] as! UInt64
                let fileName = fileURL.lastPathComponent
                files.append(File(url: fileURL, name: fileName, size: fileSize))
            }
        } catch {
            print("Error while enumerating files \(iCloudDocumentsURL.path): \(error.localizedDescription)")
        }
        
        return files
    }
    
    func deleteiCloudFile(index: Int) {
        let file = iCloudFiles[index]
        self.iCloudFiles.remove(at: index)
        try? FileManager.default.removeItem(at: file.url)
    }

    func getDropBoxFiles() -> [File] {
        var files = [File]()
        
        return files
    }
    
    func deleteDropBoxFile(index: Int) {
        let file = dropBoxFiles[index]
        self.dropBoxFiles.remove(at: index)
        // remove from DropBox storage
    }
    
    func getBoxFiles() -> [File] {
        var files = [File]()
        
        return files
    }
    
    func deleteBoxFile(index: Int) {
        let file = boxFiles[index]
        self.boxFiles.remove(at: index)
        // remove from Box storage
    }
    
    @IBAction func sourceSelected(_ sender: UISegmentedControl) {
        switch getCurrentSource() {
        case "Documents":
            documentFiles = getDocumentFiles()
        case "iCloud":
            iCloudFiles = getiCloudFiles()
        case "DropBox":
            dropBoxFiles = getDropBoxFiles()
        case "Box":
            boxFiles = getBoxFiles()
        default:
            documentFiles = getDocumentFiles()
        }
        
        tableView.reloadData()
    }
    

}
