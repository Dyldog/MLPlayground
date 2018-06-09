//
//  Extensions.swift
//  MachineLearningTests
//
//  Created by ELLIOTT, Dylan on 9/6/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
