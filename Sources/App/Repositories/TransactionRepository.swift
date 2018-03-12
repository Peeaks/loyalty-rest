import Foundation
import Vapor

final class TransactionRepository { }

extension TransactionRepository: TransactionRepositoryProtocol {
    
    /// Returns all Transactions found
    func getAll() throws -> [Transaction] {
        return try Transaction.makeQuery().all()
    }
    
    /**
     Returns a Transaction with the id
     - parameters:
     - id: id as Int
     */
    func get(withId id: Int) throws -> Merchant? {
        return try Merchant.find(id)
    }
    
    /**
     Creates a Transaction
     - parameters:
     - amount: amount as UInt64
     - pointsUsed: pointsUsed as UInt64
     - formattedAmount: formattedAmount as String
     - message: message as String
     */
    func create(amount: UInt64, pointsUsed: UInt64, formattedAmount: String, message: String, merchantId: Identifier, user: User) throws -> Transaction {
        
        guard let merchant = try Merchant.find(merchantId) else {
            throw Abort(.badRequest, reason: "The Merchant for the specified Id was not found")
        }
        
        if pointsUsed > 0 {
            guard let usersCurrentPointsWithMerchant = try user.points.filter("merchant_id", .equals, merchantId).first() else {
                throw Abort(.badRequest, reason: "Error finding your points with this merchant")
            }
            
            if usersCurrentPointsWithMerchant.amount < UInt64(pointsUsed) {
                throw Abort(.badRequest, reason: "You are trying to use more points than you have")
            }
        }
    
        let amountMinusPointsUsed = amount - pointsUsed
        
        //TODO: this needs work
        let pointsEarned = merchant.pointsPercentage * Double(amountMinusPointsUsed)
        
        let transaction = Transaction(amount: amount, pointsUsed: pointsUsed, formattedAmount: formattedAmount, message: message, merchantId: merchantId, userId: user.id!, pointsEarned: UInt64(pointsEarned))
        try transaction.save()
        
        //Transaction was succesful update the points table with the new value
        try updatePoint(user, merchantId, transaction)
        
        return transaction
    }
    
    fileprivate func updatePoint(_ loggedInUser: User, _ merchantId: Identifier, _ transaction: Transaction) throws {
        //Find the users points and filter based on merchantId
        do {
            if let point = try loggedInUser.points.filter("merchant_id", .equals, merchantId).first() {
                point.amount -= transaction.pointsUsed
                point.amount += transaction.pointsEarned
                try point.save()
            } else {
                try Point(amount: transaction.pointsEarned, merchantId: transaction.merchantId, userId: transaction.userId).save()
            }
        } catch let error {
            throw Abort(.badRequest, reason: error.localizedDescription)
        }
    }

}
