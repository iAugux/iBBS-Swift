//
//  NSUserDefaults+Extension.swift
//
//  Created by Augus on 2/15/16.
//  Copyright © 2016 iAugus. All rights reserved.
//

import Foundation


extension NSUserDefaults {
    
    func getBool(key: String, defaultKeyValue: Bool) -> Bool {
        if valueForKey(key) == nil {
            setBool(defaultKeyValue, forKey: key)
            synchronize()
        }
        return boolForKey(key)
    }
}

extension NSUserDefaults {
    
    func getInteger(key: String, defaultKeyValue: Int) -> Int {
        if valueForKey(key) == nil {
            setInteger(defaultKeyValue, forKey: key)
            synchronize()
        }
        return integerForKey(key)
    }
}

extension NSUserDefaults {
    
    func getDouble(key: String, defaultKeyValue: Double) -> Double {
        if valueForKey(key) == nil {
            setDouble(defaultKeyValue, forKey: key)
            synchronize()
        }
        return doubleForKey(key)
    }
}

extension NSUserDefaults {
    
    func getObject(key: String, defaultkeyValue: AnyObject) -> AnyObject? {
        if objectForKey(key) == nil {
            setObject(defaultkeyValue, forKey: key)
            synchronize()
        }
        return objectForKey(key)
    }
}


// MARK: -

extension NSUserDefaults {
    
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = dataForKey(key) {
            color = NSKeyedUnarchiver.unarchiveObjectWithData(colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedDataWithRootObject(color)
        }
        setObject(colorData, forKey: key)
    }
}

extension NSUserDefaults {
    
    func setArchivedData(object: AnyObject?, forKey key: String) {
        var data: NSData?
        if let object = object {
            data = NSKeyedArchiver.archivedDataWithRootObject(object)
        }
        setObject(data, forKey: key)
    }
    
    func unarchiveObjectWithDataForKey(key: String) -> AnyObject? {
        guard let object = objectForKey(key) else { return nil }
        guard let data = object as? NSData else { return nil }
        return NSKeyedUnarchiver.unarchiveObjectWithData(data)
    }
}
