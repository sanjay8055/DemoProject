//
//  StepProcessDelegate.swift
//  ZipID
//
//  Created by Damien Hill on 18/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

protocol StepProcessDelegate {
    func didComplete(success: Bool, responses: Array<Response?>)
    func didCancel()
}