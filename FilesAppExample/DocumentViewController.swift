//
//  DocumentViewController.swift
//  FilesAppExample
//
//  Created by Dale Musser on 4/23/18.
//  Copyright © 2018 Dale Musser. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var destinationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func save(_ sender: Any) {
        guard let fileName = titleTextField.text,
              let content = contentTextView.text else {
            return
        }
        
        let choiceIndex = destinationSegmentedControl.selectedSegmentIndex
        let choiceTitle = destinationSegmentedControl.titleForSegment(at: choiceIndex)
        
        switch (choiceTitle) {
        case "Documents":
            saveFileInDocuments(fileName: fileName, content: content)
        case "iCloud":
            saveFileIniCloud(fileName: fileName, content: content)
        case "DropBox":
            saveFileInDropBox(fileName: fileName, content: content)
        case "Box":
            saveFileInBox(fileName: fileName, content: content)
        default:
            saveFileInDocuments(fileName: fileName, content: content)
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func saveFileInBox(fileName: String, content: String) {
        
    }
    
    func saveFileInDropBox(fileName: String, content: String) {
        
    }
    
    func saveFileIniCloud(fileName: String, content: String) {
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents").appendingPathComponent(fileName) else {
            return
        }
        
        do {
            try content.write(to: iCloudDocumentsURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    func saveFileInDocuments(fileName: String, content: String) {
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    

}
