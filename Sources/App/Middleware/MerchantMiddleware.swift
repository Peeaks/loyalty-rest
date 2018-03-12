import Foundation
import Vapor

class MerchantMiddleware: Middleware {
    
    /// Middleware handling Authorization for the Merchant role
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        if try request.user().role.get()?.type == "admin"  {
            return try next.respond(to: request)
        }
        
        if try request.user().role.get()?.type != "merchant"  {
            throw Abort.unauthorized
        }
        
        
        return try next.respond(to: request)
    }
    
}
