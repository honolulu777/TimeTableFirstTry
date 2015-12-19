//
//  DeviceSupport.swift
//  Timetable App
//
//  Created by Aurel Feer on 19.12.15.
//  Copyright © 2015 Aurel Feer. All rights reserved.
//

import UIKit

class DeviceSupport {
    
    func getAbsoluteDisplayHeight() -> CGFloat {
        let orientation = UIApplication.sharedApplication().statusBarOrientation

        if orientation == .Portrait || orientation == .PortraitUpsideDown {
            return UIScreen.mainScreen().bounds.height
        } else {
            return UIScreen.mainScreen().bounds.width
        }
        
    }
    
    func getAbsoluteDisplayWidth() -> CGFloat {
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        
        if orientation == .Portrait || orientation == .PortraitUpsideDown {
            return UIScreen.mainScreen().bounds.width
        } else {
            return UIScreen.mainScreen().bounds.height
        }

    }
}