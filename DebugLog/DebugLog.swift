//
//  DebugLog.swift
//  DebugLog
//
//  Created by Yasuhiro Inami on 2014/06/22.
//  Copyright (c) 2014年 Inami Yasuhiro. All rights reserved.
//

import Foundation

public struct DebugLog
{
    private static let _lock = NSObject()
    
    private static let _dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    private static func _currentDateString() -> String
    {
        return self._dateFormatter.stringFromDate(NSDate())
    }
    
    public static var printHandler: (Any!, String, String, Int) -> Void = { body, filename, functionName, line in

        let dateString = DebugLog._currentDateString()

        if body == nil {
            print("\(dateString) [\(filename).\(functionName):\(line)]")    // print functionName
            return
        }
        
        if let body = body as? String {
            if body.characters.count == 0 {
                print("") // print break
                return
            }
        }
        
        print("\(dateString) [\(filename):\(line)] \(body)")
    }
    
    public static func print(body: Any! = nil, var filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__)
    {
#if DEBUG
    
        objc_sync_enter(_lock)
    
        filename = ((filename as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        self.printHandler(body, filename, functionName, line)
    
        objc_sync_exit(_lock)
    
#endif
    }
}

/// LOG() = prints __FUNCTION__
public func LOG(filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__)
{
#if DEBUG
    
    DebugLog.print(nil, filename: filename, functionName: functionName, line: line)
    
#endif
}

/// LOG(...) = println
public func LOG(body: Any, filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__)
{
#if DEBUG
    
    DebugLog.print(body, filename: filename, functionName: functionName, line: line)
    
#endif
}

/// LOG_OBJECT(myObject) = println("myObject = ...")
public func LOG_OBJECT(body: Any, filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__)
{
#if DEBUG
    
    if let reader = DDFileReader(filePath: filename) {
        let logBody = "\(reader.readLogLine(line)) = \(body)"
        
        LOG(logBody, filename: filename, functionName: functionName, line: line)
    }
    
#endif
}

public func LOG_OBJECT(body: AnyClass, filename: String = __FILE__, functionName: String = __FUNCTION__, line: Int = __LINE__)
{
#if DEBUG
    
    _ = DDFileReader(filePath: filename)
    
    let classInfo: DebugLog.ParsedClass = DebugLog.parseClass(body)
    let classString = classInfo.moduleName != nil ? "\(classInfo.moduleName!).\(classInfo.name)" : "\(classInfo.name)"
    
    LOG_OBJECT(classString, filename: filename, functionName: functionName, line: line)
    
    // comment-out: requires method name demangling
//    LOG_OBJECT("\(class_getName(body))", filename: filename, functionName: functionName, line: line)
    
#endif
}

