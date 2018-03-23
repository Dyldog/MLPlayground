import Foundation
import CoreML

class ModelDescription: Codable {
  let id: String
  let name: String
  let networkURL: URL
    var savedPath: String?
  var compiledPath: String?

  init(id: String? = nil, name: String, networkURL: URL, savedPath: String? = nil, compiledPath: String? = nil) {
    self.id = id ?? NSUUID().uuidString
    self.name = name
    self.networkURL = networkURL
    self.savedPath = savedPath
    self.compiledPath = compiledPath
  }
    
    func savedURL(in directoryURL: URL) -> URL? {
        guard let savedPath = savedPath else { return nil }
        return directoryURL.appendingPathComponent(savedPath)
    }
    
    func compiledURL(in directoryURL: URL) -> URL? {
        guard let compiledPath = compiledPath else { return nil }
        return directoryURL.appendingPathComponent(compiledPath)
    }

  func mlModel(in directoryURL: URL) throws -> MLModel {
    guard let compiledURL = self.compiledURL(in: directoryURL) else { throw ModelManagerError.noSavedURL }
    return try MLModel(contentsOf:compiledURL)
  }
}
