//
//  ViewController.swift
//  TasksProj
//
//  Created by lch on 29/05/2020.
//  Copyright © 2020 lch. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet weak var outputText: NSTextView!
    @IBOutlet weak var projPath: NSPathControl!
    @IBOutlet weak var repoPath: NSPathControl!
    @IBOutlet weak var targetName: NSTextField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var buildButton: NSButton!
    
    dynamic var isRunning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.stopButton.isEnabled = false
   
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func handleAction(_ sender: NSButton) {
        if sender == self.buildButton {
            self.startTask()
        }
    }
    
    func startTask() {
        //1.
        outputText.string = ""
        if let projectURL = projPath.url,let repositoryURL = repoPath.url {
            let projectLocation = projectURL.path
            let finalLocation = repositoryURL.path
            let projectName = projectURL.lastPathComponent
             let xcodeProjectFile = projectLocation + "/\(projectName).xcodeproj"
            let buildLocation = projectLocation + "/build"
            //5.
            var arguments:[String] = []
            arguments.append(xcodeProjectFile)
            arguments.append(targetName.stringValue)
            arguments.append(buildLocation)
            arguments.append(projectName)
            arguments.append(finalLocation)
            
            //6.
            buildButton.isEnabled = false
            spinner.startAnimation(self)
            stopButton.isEnabled = true
            
            guard let path = Bundle.main.path(forResource: "Script", ofType: "sh") else {
                self.buildButton.isEnabled = true
                self.spinner.stopAnimation(self)
                self.isRunning = false
                self.stopButton.isEnabled = false
                return
            }
            isRunning = true
            
            HHShell.runScript(path, arguments, terminationHandler: {
                DispatchQueue.main.async {
                    self.buildButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                    self.stopButton.isEnabled = false
                }
            }) { (output, err) in
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + output + "\n" + err
                self.outputText.string = nextOutput
                
                let range = NSRange(location: nextOutput.count, length: 0)
                self.outputText.scrollRangeToVisible(range)
            }
        }
        
    }
  
}

        
