import Foundation
import Vapor
import AuthProvider

final class LogController {
    
    private let droplet: Droplet
    private var logRepository: LogRepositoryProtocol
    
    /// Initializes the LogController
    init(droplet: Droplet) {
        self.droplet = droplet
        self.logRepository = LogRepository()
    }
    
    /// Adds the defined routes to the droplet
    func addRoutes() {
        droplet.adminAuthed.get("logs", handler: getLogs)
        droplet.adminAuthed.get("logs", String.parameter, handler: getLogsForSpecificRequest)
    }
    
    /**
     When consumers call 'GET' on '/logs' all Logs are returned.
     Only available with valid token and admin role.
     */
    func getLogs(request: Request) throws -> ResponseRepresentable {
        return try logRepository.getAll().makeJSON()
    }
    
    /**
     When consumers call 'GET' on '/logs' with a requestType, all logs with that requestType is returned.
     Only available with valid token and admin role.
     */
    func getLogsForSpecificRequest(request: Request) throws -> ResponseRepresentable {
        let requestType = try request.parameters.next(String.self)
        
        return try logRepository.get(withRequestType: requestType).makeJSON()
    }
    
}
