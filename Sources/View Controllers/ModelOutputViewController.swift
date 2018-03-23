//
//  ModelOutputViewControllere.swift
//  MachineLearningTests
//
//  Created by ELLIOTT, Dylan on 21/2/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreML

class ModelOutputViewController: UITableViewController {
    
    let mlModel: MLModel
    let inputs: MLFeatureProvider
    var outputs: MLFeatureProvider!
    lazy var outputNames: [String] = {
        return Array(self.outputs.featureNames)
    }()
    
    init(mlModel: MLModel, inputs: MLFeatureProvider) {
        self.mlModel = mlModel
        self.inputs = inputs
        
        super.init(style: .grouped)
        
        self.outputs = produceOutput()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func produceOutput() -> MLFeatureProvider {
        return try! mlModel.prediction(from: inputs)
    }
    
    // MARK: - UITableViewDataSource
    
    override  func numberOfSections(in tableView: UITableView) -> Int {
        return outputNames.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let feature = outputs.featureValue(for: outputNames[section]) else { fatalError() } // TODO: Error
        
        switch feature.type {
        case .dictionary:
            return feature.dictionaryValue.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .value1, reuseIdentifier: cellId)
        
        let featureName = outputNames[indexPath.section]
        guard let featureValue = outputs.featureValue(for: featureName) else { fatalError() } // TODO: Error
        
        cell.textLabel?.text = featureName
        cell.detailTextLabel?.numberOfLines = 2
        
        switch featureValue.type {
        case .string, .int64, .double:
            cell.detailTextLabel?.text = featureValue.stringValue
        case .image:
            cell.detailTextLabel?.text = "Images in progress"
        case .dictionary:
            let sortedKeys = featureValue.dictionaryValue.keys.sorted(by: { key1, key2 -> Bool in
                let string1 = String(describing: key1)
                let string2 = String(describing: key2)
                
                return string1.compare(string2) == .orderedAscending
            })
            
            let currentKey = sortedKeys[indexPath.row]
            let currentValue = featureValue.dictionaryValue[currentKey]
            
            cell.textLabel?.text = String(describing: currentKey)
            cell.detailTextLabel?.text = currentValue?.stringValue
        
        case .invalid:
            cell.detailTextLabel?.text = "Invalid type"
        case .multiArray:
            cell.detailTextLabel?.text = "Multi-array type"
        }
        
        return cell
    }
}
