//
//  ModelManager.swift
//  MachineLearningTests
//
//  Created by Dylan Elliot on 15/2/18.
//  Copyright © 2018 Dylan Elliott. All rights reserved.
//

import Foundation
import CoreML

enum ModelManagerError: Error {
    case noSavedURL
    case noCompileURL
}

class NetworkClient {
    // Downloads the file at the URL and returns the local URL for the saved file
    static func downloadFile(at url: URL, completion:@escaping ((URL) -> Void)) {
        URLSession.shared.downloadTask(with: url) { (localURL, response, error) in
            guard let localURL = localURL else { fatalError() }
            completion(localURL)
        }.resume()
    }
}

class FileStorage {
    static let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    static let modelJSONFilename = "ModelsDescriptions.json"
    static var modelJSONURL = documentDirectoryURL.appendingPathComponent(modelJSONFilename)
    
    static func moveFile(at url: URL, to path: String) {
        let newURL = documentDirectoryURL.appendingPathComponent(path)
        try? FileManager.default.moveItem(at: url, to: newURL)
    }
    
    static func deleteFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}

class ModelManager {
    

//    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//    let documentsDirectory = paths[0]
//    return URL(string: documentsDirectory)!
    
    static var shared = ModelManager()
    
    private var models: [String: ModelDescription] = [:]
    
    init() {
        loadModels()
        
//        if models.count == 0 {
//            let model = ModelDescription(name: "SqueezeNet", networkURL: URL(string: "https://docs-assets.developer.apple.com/coreml/models/SqueezeNet.mlmodel")!)
//            models = [ model.id: model ]
//            saveModels()
//        }
    }
    
    // TODO: Move somewhere else
//    static func saveFile(fileName: String, data: Data) -> URL {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        let filePath = "\(documentsDirectory)/\(fileName)"
//        let fileURL = URL(fileURLWithPath: filePath)
//
//        try! data.write(to: fileURL)
//
//        return fileURL
//    }
    
//    func removeInvalidFileURLs(in models: [String: ModelDescription]) -> [String: ModelDescription] {
//        let fileManager = FileManager.default
//        let newModels = models.mapValues { oldModel -> ModelDescription in
//            let newModel = ModelDescription(id: oldModel.id, name: oldModel.name, networkURL: oldModel.networkURL, savedPath: nil, compiledPath: nil)
//
//            if let savedPath = oldModel.savedPath, let savedURL = oldModel.savedURL(in: self.documentDirectoryURL),
//                fileManager.fileExists(atPath: savedURL.absoluteString) {
//                newModel.savedPath = savedPath
//            }
//
//            if let compiledPath = oldModel.compiledPath, let compiledURL = oldModel.compiledURL(in: self.documentDirectoryURL),
//                fileManager.fileExists(atPath: compiledURL.relativeString) {
//                newModel.compiledPath = compiledPath
//            }
//
//            return newModel
//        }
//
//        return newModels
//    }

    func saveModels() {
        let modelData = try! JSONEncoder().encode(models)
        try! modelData.write(to: FileStorage.modelJSONURL)
        
        // TODO: Error
    }
    
    func loadModels() {
        let modelData = try? Data(contentsOf: FileStorage.modelJSONURL)
        
        if let modelData = modelData {
            let loadedModels = try! JSONDecoder().decode([String: ModelDescription].self, from: modelData)
            models = loadedModels // removeInvalidFileURLs(in: loadedModels)
            saveModels()
            // TODO: Error
            
        }
    }
    
    func downloadModel(withID id: String, completion:(() -> Void)? = nil) {
        guard let model = models[id] else { return } //TODO: Error
        
        let networkURL = model.networkURL
        NetworkClient.downloadFile(at: networkURL) { url in
            
            let newFilename = networkURL.lastPathComponent
            
            FileStorage.moveFile(at: url, to: newFilename)
            self.models[id]?.savedPath = newFilename
            self.saveModels()
            
            
            completion?()
        }
    }
    
    func compileModel(withID id: String, completion:(() -> Void)? = nil) {
        guard let model = models[id] else { return } // TODO: Error
        
        guard let savedURL = model.savedURL(in: FileStorage.documentDirectoryURL) else { return } // TODO: Error
        
        do {
            let compiledURL = try MLModel.compileModel(at: savedURL)
            
            let newFilename = savedURL.lastPathComponent.replacingOccurrences(of: "mlmodel", with: "mlmodelc")
            FileStorage.moveFile(at: compiledURL, to: newFilename)
            self.models[id]?.compiledPath = newFilename
            saveModels()
        } catch {
            // TODO: Error
        }
        
        completion?()
    }
    
    var numberOfModels: Int {
        return models.count
    }
    
    func model(at index: Int) -> ModelDescription {
        return Array(ModelManager.shared.models.values)[index]
    }
    
    func model(withID id: String) -> ModelDescription? {
        return self.models[id]
    }
    
    func newModel(withName name: String, networkURL: URL) {
        let model = ModelDescription(name: name, networkURL: networkURL)
        models[model.id] = model
        saveModels()
    }
    
    func removeModel(withID id: String) {
        guard let model = self.model(withID: id) else { return }
        if let savedURL = model.savedURL(in: FileStorage.documentDirectoryURL) {
            FileStorage.deleteFile(at: savedURL)
        }
        
        if let compiledURL = model.compiledURL(in: FileStorage.documentDirectoryURL) {
            FileStorage.deleteFile(at: compiledURL)
        }
        
        self.models.removeValue(forKey: id)
        saveModels()
    }
}
