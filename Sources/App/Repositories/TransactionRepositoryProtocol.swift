import Foundation
import Vapor

protocol TransactionRepositoryProtocol: class {
    
    /// Returns all Transactions found
    func getAll() throws -> [Transaction]
    
    /**
     Returns a Transaction with the id
     - parameters:
     - id: id as Int
     */
    func get(withId id: Int) throws -> Merchant?
    
    /**
     Creates a Transaction
     - parameters:
     - amount: amount as UInt64
     - pointsUsed: pointsUsed as UInt64
     - formattedAmount: formattedAmount as String
     - message: message as String
     */
    func create(amount: UInt64, pointsUsed: UInt64, formattedAmount: String, message: String, merchantId: Identifier, user: User) throws -> Transaction
}
