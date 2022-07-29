//
//  ViewTableCell.swift
//  MusicTest
//
//  Created by Farhan Mazario on 11/07/22.
//

import Foundation
import UIKit

class ViewTableCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
