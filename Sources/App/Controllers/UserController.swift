import Vapor
import HTTP
import AuthProvider
import Foundation

///RESTful interactions with our Users table
final class UserController {
    
    private let droplet: Droplet
    private var userRepository: UserRepositoryProtocol
    
    /// Initializes the UserController
    init(droplet: Droplet) {
        self.droplet = droplet
        self.userRepository = UserRepository()
    }
    
    /// Adds the routes to the droplet
    func addRoutes() {
        droplet.post("register", handler: register)
        droplet.passwordAuthed.post("login", handler: login)
        
        droplet.tokenAuthed.put("changePassword", handler: changePassword)
        droplet.tokenAuthed.put("users", handler: updateUser)
        droplet.tokenAuthed.post("logout", handler: logout)
        
        droplet.tokenAuthed.get("me", handler: getLoggedInUser)
        droplet.tokenAuthed.group("me") { me in
            me.get("points", handler: getPointsForLoggedInUser)
            me.get("points", Int.parameter, handler: getPointsForMerchantForLoggedInUser)
            me.get("merchants", handler: getMerchantsForLoggedInUser)
            me.group("merchants") { merchants in
                merchants.get("transactions", handler: getTransactionsForMerchant)
            }
            me.get("transactions", handler: getTransactionsForLoggedInUserPagination)
        }
        
        droplet.adminAuthed.get("users", handler: getAllUsers)
        droplet.adminAuthed.get("users", Int.parameter, handler: getUser)
    }
    
    /**
     When consumers call 'POST' on '/register' with valid JSON
     construct and save the user.
     ```
     {
     "email": "test@test.dk",
     "password": "123456",
     "name": "Your name"
     }
     */
    func register(request: Request) throws -> ResponseRepresentable {
        guard let email = request.data["email"]?.string else {
            throw Abort(.badRequest, reason: "Please provide e-mail")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide password")
        }
        
        guard let name = request.data["name"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide name")
        }
        if name.trim().isEmpty {
            throw Abort(.badRequest, reason: "Plese provide name")
        }
        
        let user = try userRepository.register(email: email, password: password, name: name)
        
        return try user.makeJSON()
    }
    
    /**
     When consumers call 'PUT' on '/changePassword' with valid JSON
     check if the old passwords match and change it to the new password.
     ```
     {
     "oldPassword": "123456",
     "newPassword": "654321"
     }
     */
    func changePassword(request: Request) throws -> ResponseRepresentable {
        guard let oldPassword = request.data["oldPassword"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide old password")
        }
        guard let newPassword = request.data["newPassword"]?.string else {
            throw Abort(.badRequest, reason: "Plese provide new password")
        }
        
        let loggedInUser = try request.user()
        let success = try userRepository.changePassword(oldPassword: oldPassword, newPassword: newPassword, loggedInUser: loggedInUser)
        
        return try JSON(node: ["succes" : success])
    }
    
    /**
     When consumers call 'POST' on '/login' with valid Basic Auth information
     the user will be provided with a token.
     */
    func login(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try userRepository.login(user: user)
        
        return try JSON(node: ["token" : token.token, "user" : try user.makeJSON()])
    }
    
    /**
     When consumers call 'POST' on 'logout' the current token will be deleted.
     Only available with valid token.
     */
    func logout(request: Request) throws -> ResponseRepresentable {
        guard let tokenStr = request.auth.header?.bearer?.string else {
            throw Abort.badRequest
        }
        
        try userRepository.logout(tokenString: tokenStr)
        
        return Response(status: .ok)
    }
    
    /**
     When the consumer calls 'GET' on a specific resource, ie:
     '/users/2' we should show that specific user.
     Only available with valid token.
     */
    func getUser(request: Request) throws -> ResponseRepresentable {
        let userId = try request.parameters.next(Int.self)
        
        guard let user = try userRepository.get(withId: userId) else {
            throw Abort(.badRequest, reason: "Couldn't find any user with Id: \(userId)")
        }
        
        return user
    }
    
    /**
     When users call 'GET' on '/users'
     it should return an index of all available users.
     Only available with valid token.
     */
    func getAllUsers(request: Request) throws -> ResponseRepresentable {
        return try userRepository.getAll().makeJSON()
    }
    
    /**
     When users call 'PUT' on '/users'
     it should update the logged in User
     Only available with valid token.
     ```
     {
     "name": "Your name"
     }
     */
    func updateUser(request: Request) throws -> ResponseRepresentable {
        guard let name = request.json?["name"]?.string else {
            throw Abort(.badRequest, reason: "Please provide a name")
        }
        
        let user = try userRepository.update(name: name, userId: request.user().id!)
        
        return try user.makeJSON()
    }
    
    /**
     When users call 'GET' on '/me'
     it should return information about the logged in user.
     Only available with valid token.
     */
    func getLoggedInUser(request: Request) throws -> ResponseRepresentable {
        return try request.user().makeJSON()
    }
    
    /**
     When users call 'GET' on '/me/points'
     it should return information about the logged in users points.
     Only available with valid token.
     */
    func getPointsForLoggedInUser(request: Request) throws -> ResponseRepresentable {
        return try userRepository.getPointsForUser(user: request.user()).makeJSON()
    }
    
    /**
     When users call 'GET' on '/me/merchants'
     it should return information about the logged in users created merchants.
     Only available with valid token.
     */
    func getMerchantsForLoggedInUser(request: Request) throws -> ResponseRepresentable {
        return try userRepository.getMerchantsForUser(user: request.user()).makeJSON()
    }
    
    
    /**
     When users call 'GET' on '/me/transactions?amount=8&page=2'
     it should return information about the logged in users transactions.
     Returning the sent in amount of transactions on the sent in page.
     Only available with valid token.
     */
    func getTransactionsForLoggedInUserPagination(request: Request) throws -> ResponseRepresentable {
        guard let amount = request.query?["amount"]?.int else {
            throw Abort(.badRequest, reason: "Please send in amount")
        }
        guard let page = request.query?["page"]?.int else {
            throw Abort(.badRequest, reason: "Please send in page")
        }
        
        return try userRepository.getTransactionsForUser(amount: amount, page: page, user: request.user()).makeJSON()
    }
    
    /**
     When users call 'GET' on '/me/points/ID'
     it should return information about the logged in users points with the sent in merchant ID.
     Only available with valid token.
     */
    func getPointsForMerchantForLoggedInUser(request: Request) throws -> ResponseRepresentable {
        let merchantId = try request.parameters.next(Int.self)
        
        guard let point = try userRepository.getPointsForUserForSpecificMerchant(merchantId: merchantId, user: request.user()) else {
            throw Abort(.badRequest, reason: "No points found for your user with merchant id: \(merchantId)")
        }
        return try point.makeJSON()
    }
    
    /**
     When users call 'GET' on '/me/merchants/transactions?id=1amount=8&page=2'
     it should return information about the Merchants transactions.
     Returning the sent in amount of transactions on the sent in page.
     Only available with valid token.
     */
    func getTransactionsForMerchant(request: Request) throws -> ResponseRepresentable {
        guard let id = request.query?["id"]?.int else {
            throw Abort(.badRequest, reason: "Please provide Id for the Merchant")
        }
        guard let amount = request.query?["amount"]?.int else {
            throw Abort(.badRequest, reason: "Please provide amount for pagination")
        }
        guard let page = request.query?["page"]?.int else {
            throw Abort(.badRequest, reason: "Please provide page for pagination")
        }
        
        let loggedInUser = try request.user()
        
        return try userRepository.getTransactionsForMerchant(amount: amount, page: page, user: loggedInUser, merchantId: id).makeJSON()
    }
    
}
