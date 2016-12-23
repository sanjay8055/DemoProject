//
//  DocumentCell.swift
//  ZipID
//
//  Created by Damien Hill on 2/05/2016.
//  Copyright © 2016 ZipID. All rights reserved.
//

import Foundation
import UIKit

@objc class DocumentCell: UITableViewCell {
    
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var documentLabel: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectedIcon.image = selected ? UIImage(named: "ClientCompleteIcon24") : nil
    }
}
