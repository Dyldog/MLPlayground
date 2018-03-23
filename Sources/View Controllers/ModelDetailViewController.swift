//
//  ModelDetailViewController.swift
//  MachineLearningTests
//
//  Created by Dylan Elliot on 15/2/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import UIKit
import CoreML
import Eureka

extension MLFeatureType: CustomStringConvertible {
  public var description: String {
    switch self {
    case .image:
      return "image"
    case .invalid:
      return "invalid"
    case .int64:
      return "int64"
    case .double:
      return "double"
    case .string:
      return "string"
    case .multiArray:
      return "multiArray"
    case .dictionary:
      return "dictionary"
    }
  }
}

class ModelDetailViewController: FormViewController {
  var model: ModelDescription?
  @IBOutlet weak var textView: UITextView!

  init(model: ModelDescription) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

//  func setText(text: String) {
//    DispatchQueue.main.async {
//      self.textView.text = text
//    }
//  }

//  func updateTextField() {
//    DispatchQueue.main.async {
//      guard let mlModel = try! self.model?.mlModel(in: FileStorage.documentDirectoryURL) else { return }
//
//      var lines = [String]()
//
//      lines += ["Inputs"]
//      lines += mlModel.modelDescription.inputDescriptionsByName.values.map({ feature in
//        "\(feature.name): \(feature.type.description)"
//      })
//
//      lines += [""]
//
//      lines += ["Outputs"]
//      lines += mlModel.modelDescription.outputDescriptionsByName.values.map({ feature in
//        "\(feature.name): \(feature.type.description)"
//      })
//
//      self.setText(text: lines.joined(separator: "\n"))
//    }
//  }

  override func viewDidLoad() {
    super .viewDidLoad()
    
    guard let model = model else { return }
    let modelSaved = model.savedPath != nil
    let modelCompiled = model.compiledPath != nil
    
    form +++ Section()
        <<< LabelRow() {
            $0.title = "Downloaded"
            $0.value = (modelSaved ? "true" : "false")
        }
        <<< LabelRow() {
            $0.title = "Compiled"
            $0.value = (modelCompiled ? "true" : "false")
        }
    
    if modelCompiled {
        guard let mlModel = try! self.model?.mlModel(in: FileStorage.documentDirectoryURL)
            else { return }
        
        let inputSection = Section()
        inputSection.header = HeaderFooterView(title: "Inputs")
        form +++ inputSection
        
        for inputDescription in mlModel.modelDescription.inputDescriptionsByName.values {
            inputSection <<< LabelRow() {
                $0.title = inputDescription.name
                $0.value = inputDescription.type.description
            }
        }
        
        let outputSection = Section()
        outputSection.header = HeaderFooterView(title: "Outputs")
        form +++ outputSection
        
        for outputDescription in mlModel.modelDescription.outputDescriptionsByName.values {
            outputSection <<< LabelRow() {
                $0.title = outputDescription.name
                $0.value = outputDescription.type.description
            }
        }
        
        
        let metadataSection = Section()
        metadataSection.header = HeaderFooterView(title: "Metadata")
        form +++ metadataSection
        for (key, value) in mlModel.modelDescription.metadata {
            metadataSection <<< LabelRow() {
                $0.title = key.rawValue
                $0.value = String(describing: value)
            }
        }
        
        form +++ Section()
            <<< ButtonRow() {
                $0.title = "Test Model"
                $0.onCellSelection({ _,_ in self.testButtonTapped() })
            }
    }
    
    

    let displayStep = self.updateView
    let compileStep = {
      //self.setText(text: "Compiling model...")
      ModelManager.shared.compileModel(withID: model.id) {
        displayStep()
      }
    }
    let downloadStep = {
      DispatchQueue.global().async {
        //self.setText(text: "Downloading model...")
        ModelManager.shared.downloadModel(withID: model.id) {
          compileStep()
        }
      }
    }

    if modelSaved == false {
      downloadStep()
    } else if modelCompiled == false {
      compileStep()
    } else {
      displayStep()
    }
  }

  func updateView() {
    
  }

  @IBAction func testButtonTapped() {
    guard let model = model, let mlModel = try? model.mlModel(in: FileStorage.documentDirectoryURL) else { return } // TODO: Error
    // TODO: Change to TEST BUTTON
    let inputViewController = ModelInputViewController(mlModel: mlModel)
    self.navigationController?.pushViewController(inputViewController, animated: true)
  }
}
