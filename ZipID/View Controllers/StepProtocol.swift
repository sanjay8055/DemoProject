//
//  StepProtocol.swift
//  ZipID
//
//  Created by Damien Hill on 17/11/2015.
//  Copyright © 2015 ZipID. All rights reserved.
//

import Foundation

protocol StepDelegate {
    func didSelectNext(step: Step, option: StepOption?, viewController: StepProtocol)
    func didCancel()
}

protocol StepProtocol {
    func getResponse() -> Response?
}