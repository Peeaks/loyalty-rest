import Foundation
import Vapor
import AuthProvider

final class TransactionController {
    
    private let droplet: Droplet
    private var transactionRepository: TransactionRepositoryProtocol
    
    /// Initializes the TransactionController
    init(droplet: Droplet) {
        self.droplet = droplet 
        self.transactionRepository = TransactionRepository()
    }
    
    /// Adds the routes to the droplet
    func addRoutes() {
        droplet.tokenAuthed.post("transactions", handler: createTransaction)
        
        droplet.adminAuthed.get("transactions", handler: getAllTransactions)
        droplet.adminAuthed.get("transactions", Int.parameter, handler: getTransaction)
    }
    
    /**
     When consumers call 'POST' on '/transactions' with valid JSON
     construct and save the Transaction.
     Only available with valid token.
     ```
     {
         "amount": 500,
         "pointsUsed": 0,
         "formattedAmount": "$25",
         "message": "",
         "merchantId": 2
     }
     */
    func createTransaction(request: Request) throws -> ResponseRepresentable {
        
        guard let amount = request.data["amount"]?.uint else {
            throw Abort(.badRequest, reason: "Please provide amount")
        }
        guard let pointsUsed = request.data["pointsUsed"]?.uint else {
            throw Abort(.badRequest, reason: "Please provide points")
        }
        guard let formattedAmount = request.data["formattedAmount"]?.string else {
            throw Abort(.badRequest, reason: "Please provide formattedAmount")
        }
        guard var message = request.data["message"]?.string else {
            throw Abort(.badRequest, reason: "Please provide message")
        }
        guard let merchantId = request.data["merchantId"]?.int else {
            throw Abort(.badRequest, reason: "Please provide the Id of the Merchant")
        }
        guard let merchant = try Merchant.find(merchantId) else {
            throw Abort(.badRequest, reason: "The Merchant for the specified Id was not found")
        }
        
        if message.isEmpty {
            message = "No message"
        }
        
        return try transactionRepository.create(amount: UInt64(amount), pointsUsed: UInt64(pointsUsed), formattedAmount: formattedAmount, message: message, merchantId: merchant.id!, user: request.user())
    }
    
    /**
     When users call 'GET' on '/transaction'
     it should return an index of all available Transactions.
     Only available with valid token and Admin role.
     */
    func getAllTransactions(request: Request) throws -> ResponseRepresentable {
        return try transactionRepository.getAll().makeJSON()
    }
    
    /**
     When users call 'GET' on '/transaction/:Id'
     it should return the Transaction with the specified Id.
     Only available with valid token and Admin role.
     */
    func getTransaction(request: Request) throws -> ResponseRepresentable {
        let transactionId = try request.parameters.next(Int.self)
        
        guard let tranaction = try transactionRepository.get(withId: transactionId) else {
            throw Abort(.badRequest, reason: "No transaction found with Id: \(transactionId)")
        }
        
        return try tranaction.makeJSON()
    }
    
}
