import Vapor
import HTTP

class AdminMiddleware: Middleware {

    /// Middleware handling Authorization for the Admin role
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {

        if try request.user().role.get()?.type != "admin" {
            throw Abort.unauthorized
        }
        
        return try next.respond(to: request)
    }
}
