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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let featureName = outputNames[indexPath.section]
        guard let featureValue = outputs.featureValue(for: featureName) else { fatalError() } // TODO: Error
        
        switch featureValue.type {
        case .string, .int64, .double: return numberCell(for: featureValue, named: featureName, in: tableView)
        case .image: return imageCell(for: featureValue, named: featureName, in: tableView)
        case .dictionary: return dictionaryCell(in: tableView, at: indexPath)
        case .multiArray: return workInProgressCell(for: "Multi-array", named: featureName, in: tableView)
        case .sequence: return workInProgressCell(for: "Sequence", named: featureName, in: tableView)
        case .invalid:
            let cell = standardCell(named: featureName, in: tableView)
            cell.detailTextLabel?.text = "Invalid type"
            return cell
        }
    }
    
    func standardCell(named featureName: String? = nil, in tableView: UITableView) -> UITableViewCell {
        let cellId = "StandardCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) ?? UITableViewCell(style: .value1, reuseIdentifier: cellId)
        
        cell.textLabel?.text = featureName
        cell.detailTextLabel?.numberOfLines = 2
        
        return cell
    }
    
    func workInProgressCell(for featureType: String, named featureName: String, in tableView: UITableView) -> UITableViewCell {
        let cell = standardCell(named: featureName, in: tableView)
        cell.detailTextLabel?.text = "\(featureName.capitalized) outputs not implemented"
        return cell
    }
    
    func numberCell(for featureValue: MLFeatureValue, named featureName: String, in tableView: UITableView) -> UITableViewCell {
        let cell = standardCell(named: featureName, in: tableView)
        cell.detailTextLabel?.text = featureValue.stringValue
        return cell
    }
    
    func dictionaryCell(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let featureName = outputNames[indexPath.section]
        guard let featureValue = outputs.featureValue(for: featureName) else { fatalError() } // TODO: Error
        
        let cell = standardCell(in: tableView)
        
        let sortedKeys = featureValue.dictionaryValue.keys.sorted(by: { key1, key2 -> Bool in
            let string1 = String(describing: key1)
            let string2 = String(describing: key2)
            
            return string1.compare(string2) == .orderedAscending
        })
        
        let currentKey = sortedKeys[indexPath.row]
        let currentValue = featureValue.dictionaryValue[currentKey]
        
        cell.textLabel?.text = String(describing: currentKey)
        cell.detailTextLabel?.text = currentValue?.stringValue
        
        return cell
    }
    
    func imageCell(for featureValue: MLFeatureValue, named featureName: String, in tableView: UITableView) -> UITableViewCell {
        guard let cell = (tableView.dequeueReusableCell(withIdentifier: "ImageCell") ?? Bundle.main.loadNibNamed("ImageTableViewCell", owner: nil, options: nil)?.first) as? ImageTableViewCell,
            let buffer = featureValue.imageBufferValue,
            let image = UIImage(pixelBuffer: buffer) else { fatalError() }
        
        cell.label.text = featureName
        cell.bigImageView.image = image
        cell.imageAspectRatio = image.size.width / image.size.height
        return cell
    }
}
