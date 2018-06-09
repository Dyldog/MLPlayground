//
//  ImageTableViewCell.swift
//  MachineLearningTests
//
//  Created by ELLIOTT, Dylan on 9/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var aspectRatioConstraint: NSLayoutConstraint! {
        willSet {
            if let aspectRatioConstraint = aspectRatioConstraint {
                bigImageView.removeConstraint(aspectRatioConstraint)
            }
        }
    }
    @IBOutlet var bigImageView: UIImageView!
    
    var imageAspectRatio: CGFloat {
        set {
            aspectRatioConstraint = bigImageView.widthAnchor.constraint(equalTo: bigImageView.heightAnchor, multiplier: imageAspectRatio)
            NSLayoutConstraint.activate([aspectRatioConstraint])
            
        }
        get {
            return aspectRatioConstraint!.multiplier
        }
    }
}
