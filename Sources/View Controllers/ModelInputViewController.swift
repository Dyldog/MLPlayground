//
//  ModelInputViewController.swift
//  MachineLearningTests
//
//  Created by ELLIOTT, Dylan on 21/2/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreML
import Eureka
import ImageRow

class ModelInputViewController: FormViewController {
    let mlModel: MLModel
    
    init(mlModel: MLModel) {
        self.mlModel = mlModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadForm()
    }
    
    func loadForm() {
        // TODO: Create form
        
        for input in mlModel.modelDescription.inputDescriptionsByName.values {
            let section = Section()
            
            let inputName = input.name
            let inputType = input.type
            
            switch inputType {
            case .image:
                section <<< ImageRow() { row in
                    row.title = inputName
                    row.tag = inputName
                    row.sourceTypes = [.All]
                    row.clearAction = .yes(style: UIAlertActionStyle.destructive)
                }
            case .int64:
                section <<< IntRow() {
                    $0.title = inputName
                    $0.tag = inputName
                }
            case .double:
                section <<< DecimalRow() {
                    $0.title = inputName
                    $0.tag = inputName
                }
            case .string:
                section <<< TextRow() {
                    $0.title = inputName
                    $0.tag = inputName
                }
            case .dictionary, .multiArray, .sequence, .invalid:
                let dictionaryValue = input.dictionaryConstraint
                section <<< LabelRow() {
                    $0.title = inputName
                    $0.value = "Type not implemented"
                }
            }

            form +++ section
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Parse Inputs"
                $0.onCellSelection({ cell, row in self.doneButtonTapped() })
            }
    }
    
    
    
    func doneButtonTapped() {
        var mappedInputs = [String: Any]()
        
        form.values().forEach { (key, value) in
            switch value {
            case let image as UIImage:
                let valueDescriptor = mlModel.modelDescription.inputDescriptionsByName[key]
                guard let imageConstraint = valueDescriptor?.imageConstraint else { fatalError() }
                
                mappedInputs[key] = image.pixelBuffer(width: imageConstraint.pixelsWide, height: imageConstraint.pixelsHigh)
            default:
                mappedInputs[key] = value
            }
        }
        
        guard let inputFeatures = try? MLDictionaryFeatureProvider(dictionary: mappedInputs) else { return } // TODO: Error
        let outputViewController = ModelOutputViewController(mlModel: mlModel, inputs: inputFeatures)
        self.navigationController?.pushViewController(outputViewController, animated: true)
        
    }
}
