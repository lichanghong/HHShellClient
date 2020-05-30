//
//  HHShell.swift
//  TasksProj
//
//  Created by lch on 30/05/2020.
//  Copyright © 2020 lch. All rights reserved.
//

import Foundation

class HHShell {
    /// 执行shell脚本
    @discardableResult
    class func shell(command: String) -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String

        return output
    }
    
    class func runScript(_ path:String,_ arguments:[String],terminationHandler: @escaping(() -> Void), outputCallback: @escaping ((String,String) -> Void)){
//        这个path是脚本路径，一般外面传入，获取方式一般为：
//          guard let path = Bundle.main.path(forResource: "Script", ofType: "sh") else {
//              self.buildButton.isEnabled = true
//              self.spinner.stopAnimation(self)
//              self.isRunning = false
//              self.stopButton.isEnabled = false
//              return
//          }
        
        let process = Process()
        let outPip = Pipe()
        let errPip = Pipe()
        process.launchPath = path
        process.arguments = arguments
        
        process.terminationHandler = { task in
            DispatchQueue.main.async {
//                这个terminationHandler回调是往外抛的，可以更新一些UI，如下：
//                self.buildButton.isEnabled = true
//                self.spinner.stopAnimation(self)
//                self.isRunning = false
//                self.stopButton.isEnabled = false
                try? outPip.fileHandleForReading.close()
                terminationHandler()
            }
        }
        process.standardOutput = outPip
        process.standardError  = errPip
        outPip.fileHandleForReading.waitForDataInBackgroundAndNotify()
        errPip.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outPip.fileHandleForReading, queue: nil) { (notifi) in
            //4.
            let output = outPip.fileHandleForReading.availableData
            let err = errPip.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            let errString = String(data: err, encoding: String.Encoding.utf8) ?? ""
            
            //5.
            DispatchQueue.main.async(execute: {
//                这里是脚本输出的日志还有错误输出，回调在外面是处于主线程的，可以做UI更新
//                let previousOutput = self.outputText.string
//                let nextOutput = previousOutput + "\n" + outputString + "\n" + errString
//                self.outputText.string = nextOutput
//
//                let range = NSRange(location: nextOutput.count, length: 0)
//                self.outputText.scrollRangeToVisible(range)
                outputCallback(outputString,errString)
            })
            
            outPip.fileHandleForReading.waitForDataInBackgroundAndNotify()
            errPip.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        
          process.launch()
          process.waitUntilExit()
        
      }
    
    
// 这里是开启线程操作一些任务的方式
    //        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    //      //3.
    //      taskQueue.async {
    //       Thread.sleep(forTimeInterval: 2.0)
    //        DispatchQueue.main.async(execute: {
    //
    //        })
              
            //TESTING CODE
    //      }

    
}
