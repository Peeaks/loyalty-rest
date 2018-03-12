import Foundation
import Vapor

protocol UserRepositoryProtocol: class {
    
    /// Returns all Users
    func getAll() throws -> [User]
    
    /// Returns the User with the id
    func get(withId id: Int) throws -> User?
    
    /**
     Creates a User
     - parameters:
     - email: email as String
     - password: password as Name
     - name: name as String
     */
    func register(email: String, password: String, name: String) throws -> User
    
    /**
     Changes a Users password
     - parameters:
     - oldPassword: oldPassword as String
     - newPassword: newPassword as String
     - loggedInUser: user as User
     */
    func changePassword(oldPassword: String, newPassword: String, loggedInUser: User) throws -> Bool
    
    /**
     Login a user
     - parameters:
     - user: user as User
     */
    func login(user: User) throws -> AccessToken
    
    /**
     Logs out a user
     - parameters:
     - tokenString: tokenString as String
     */
    func logout(tokenString: String) throws
    
    /**
     Updates a User
     - parameters:
     - name: name as String
     - userId: userId as Identifier
     */
    func update(name: String, userId: Identifier) throws -> User
    
    /**
     Returns all Points found for a User
     - parameters:
     - user: user as User
     */
    func getPointsForUser(user: User) throws -> [Point]
    
    /**
     Returns Point found for a User for a specific Merchant
     - parameters:
     - merchantId: merchantId as Int
     - user: user as User
     */
    func getPointsForUserForSpecificMerchant(merchantId: Int, user: User) throws -> Point?
    
    /**
     Returns all Merchants created by a User
     - parameters:
     - user: user as User
     */
    func getMerchantsForUser(user: User) throws -> [Merchant]
    
    /**
     Returns all Transactions for a User with pagination
     - parameters:
     - amount: amount as Int
     - page: page as Int
     - user: user as User
     */
    func getTransactionsForUser(amount: Int, page: Int, user: User) throws -> [Transaction]
    
    /**
     Returns all Transactions for a Merchant with pagination
     - parameters:
     - amount: amount as Int
     - page: page as Int
     - user: user as User
     - merchantId: merchantId as Int
     */
    func getTransactionsForMerchant(amount: Int, page: Int, user: User, merchantId: Int) throws -> [Transaction]
}
