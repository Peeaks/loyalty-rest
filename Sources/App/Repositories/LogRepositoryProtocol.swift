import Foundation
import Vapor

protocol LogRepositoryProtocol: class {
    
    /// Returns all Logs
    func getAll() throws -> [Log]
    
    /**
     Returns all Logs with the requestType
     - parameters:
     - requestType: requestType as String
     */
    func get(withRequestType requestType: String) throws -> [Log]
}
