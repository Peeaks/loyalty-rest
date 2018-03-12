import Vapor
import AuthProvider
import Foundation

extension Droplet {
    
    var passwordAuthed: RouteBuilder { return self.grouped(PasswordAuthenticationMiddleware(User.self))}
    var tokenAuthed: RouteBuilder { return self.grouped(TokenAuthenticationMiddleware(User.self))}
    var merchantAuthed: RouteBuilder { return tokenAuthed.grouped(MerchantMiddleware())}
    var adminAuthed: RouteBuilder { return tokenAuthed.grouped(AdminMiddleware())}
    
    func setupRoutes() throws {
        let userController = UserController(droplet: self)
        userController.addRoutes()
        
        let merchantController = MerchantController(droplet: self)
        merchantController.addRoutes()
        
        let transactionController = TransactionController(droplet: self)
        transactionController.addRoutes()
        
        let logController = LogController(droplet: self)
        logController.addRoutes()
    }
}
