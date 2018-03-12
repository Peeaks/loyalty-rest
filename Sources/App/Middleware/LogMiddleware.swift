import Vapor
import HTTP

class LogMiddleware: Middleware {
    
    /// Middleware handling logging for the backend
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let log = Log(ip: request.peerHostname!, type: request.method.description, route: request.uri.path)
        try log.save()
        
        return try next.respond(to: request)
    }
    
}
