//
//  StringExtensions.swift
//  ZipID
//
//  Created by Damien Hill on 17/12/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

extension String {
    func isEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$",
            options: [.CaseInsensitive])
        
        return regex.firstMatchInString(self, options:[],
            range: NSMakeRange(0, utf16.count)) != nil
    }
}
