import Foundation
import Vapor

final class LogRepository { }

extension LogRepository: LogRepositoryProtocol {
    
    /// Returns all Logs
    func getAll() throws -> [Log] {
        return try Log.all()
    }
    
    /**
     Returns all Logs with the requestType
     - parameters:
     - requestType: requestType as String
     */
    func get(withRequestType requestType: String) throws -> [Log] {
        return try Log.makeQuery().filter("type", .equals, requestType).all()
    }
}
