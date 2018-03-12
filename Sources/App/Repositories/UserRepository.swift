import Foundation
import Vapor

final class UserRepository { }

extension UserRepository: UserRepositoryProtocol {

    /// Returns all Users
    func getAll() throws -> [User] {
        return try User.makeQuery().all()
    }
    
    /**
     Creates a User
     - parameters:
     - email: email as String
     - password: password as Name
     - name: name as String
     */
    func get(withId id: Int) throws -> User? {
        return try User.find(id)
    }
    
    /**
     Creates a User
     - parameters:
     - email: email as String
     - password: password as Name
     - name: name as String
     */
    func register(email: String, password: String, name: String) throws -> User {
        return try User.register(email: email, password: password, name: name)
    }
    
    /**
     Changes a Users password
     - parameters:
     - oldPassword: oldPassword as String
     - newPassword: newPassword as String
     - loggedInUser: user as User
     */
    func changePassword(oldPassword: String, newPassword: String, loggedInUser: User) throws -> Bool {
        return try loggedInUser.changePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    /**
     Login a user
     - parameters:
     - user: user as User
     */
    func login(user: User) throws -> AccessToken {
        let token = try AccessToken.generate(for: user)
        try token.save()
        
        return token
    }
    
    /**
     Logs out a user
     - parameters:
     - tokenString: tokenString as String
     */
    func logout(tokenString: String) throws {
        guard let token = try AccessToken.makeQuery().filter(AccessToken.Fields.token, tokenString).first() else {
            throw Abort.badRequest
        }
        
        try token.delete()
    }
    
    /**
     Updates a User
     - parameters:
     - name: name as String
     - userId: userId as Identifier
     */
    func update(name: String, userId: Identifier) throws -> User {
        guard let user = try User.find(userId) else {
            throw Abort(.badRequest, reason: "No logged in user found")
        }
        
        user.name = name
        
        try user.save()
        
        return user
    }
    
    /**
     Returns all Points found for a User
     - parameters:
     - user: user as User
     */
    func getPointsForUser(user: User) throws -> [Point] {
        return try user.points.all()
    }
    
    /**
     Returns Point found for a User for a specific Merchant
     - parameters:
     - merchantId: merchantId as Int
     - user: user as User
     */
    func getPointsForUserForSpecificMerchant(merchantId: Int, user: User) throws -> Point? {
        return try user.points.filter("merchant_id", .equals, merchantId).first()
    }
    
    /**
     Returns all Merchants created by a User
     - parameters:
     - user: user as User
     */
    func getMerchantsForUser(user: User) throws -> [Merchant] {
        return try user.merchants.all()
    }
    
    /**
     Returns all Transactions for a User with pagination
     - parameters:
     - amount: amount as Int
     - page: page as Int
     - user: user as User
     */
    func getTransactionsForUser(amount: Int, page: Int, user: User) throws -> [Transaction] {
        let startIndex = amount * page
        let pagedTransactions = try user.transactions.sort("id", .descending).limit(amount, offset: startIndex).all()
        
        return pagedTransactions
    }
    
    /**
     Returns all Transactions for a Merchant with pagination
     - parameters:
     - amount: amount as Int
     - page: page as Int
     - user: user as User
     - merchantId: merchantId as Int
     */
    func getTransactionsForMerchant(amount: Int, page: Int, user: User, merchantId: Int) throws -> [Transaction] {
        
        guard let merchant = try Merchant.find(merchantId) else {
            throw Abort(.badRequest, reason: "Couldn't find any merchants with that ID")
        }
        
        if merchant.userId != user.id {
            throw Abort(.badRequest, reason: "This Merchant does not belong to you")
        }
        
        let startIndex = amount * page
        let pagedTransactions = try merchant.transactions.sort("id", .descending).limit(amount, offset: startIndex).all()
        
        return pagedTransactions
    }
    
}

