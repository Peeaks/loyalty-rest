import Vapor
import FluentProvider
import Foundation

///Defines the users access levels and restrictions.
final class Transaction: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///Amount as a UInt64
        case amount
        ///Points as a UInt64
        case points_used
        ///FormattedAmount as a String
        case formatted_amount
        ///Message as a String
        case message
        ///MerchantId as a Identifier
        case merchant_id
        ///Payer as a Identifier
        case user_id
        ///PointsEarned as a UInt64
        case points_earned
        ///Merchant as a Merchant
        case merchant
        ///User as a User
        case user
        ///CreatedAt as a Date
        case createdAt
    }
    
    var amount: UInt64 // UInt64 because all amounts are in minor unit, i.e. øre or cent
    var pointsUsed: UInt64 // See above
    var formattedAmount: String
    var message: String
    var merchantId: Identifier
    var userId: Identifier
    var pointsEarned: UInt64
    
    init(row: Row) throws {
        self.amount = try row.get(Fields.amount)
        self.pointsUsed = try row.get(Fields.points_used)
        self.formattedAmount = try row.get(Fields.formatted_amount)
        self.message = try row.get(Fields.message)
        self.merchantId = try row.get(Fields.merchant_id)
        self.userId = try row.get(Fields.user_id)
        self.pointsEarned = try row.get(Fields.points_earned)
    }
    
    init(amount: UInt64, pointsUsed: UInt64, formattedAmount: String, message: String, merchantId: Identifier, userId: Identifier, pointsEarned: UInt64) {
        self.amount = amount
        self.pointsUsed = pointsUsed
        self.formattedAmount = formattedAmount
        self.message = message
        self.merchantId = merchantId
        self.userId = userId
        self.pointsEarned = pointsEarned
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.amount, amount)
        try row.set(Fields.points_used, pointsUsed)
        try row.set(Fields.formatted_amount, formattedAmount)
        try row.set(Fields.message, message)
        try row.set(Fields.merchant_id, merchantId)
        try row.set(Fields.user_id, userId)
        try row.set(Fields.points_earned, pointsEarned)
        
        return row
    }
}

// MARK: Preparation

extension Transaction: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.amount, optional: false)
            table.string(Fields.points_used, optional: false)
            table.string(Fields.formatted_amount, optional: false)
            table.string(Fields.message, optional: true)
            table.foreignId(for: Merchant.self)
            table.foreignId(for: User.self)
            table.string(Fields.points_earned, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Transaction: JSONRepresentable {
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.amount, amount)
        try json.set(Fields.points_used, pointsUsed)
        try json.set(Fields.formatted_amount, formattedAmount)
        try json.set(Fields.message, message)
        try json.set(Fields.merchant, self.merchant.get()?.makeJSON())
        try json.set(Fields.user, self.user.get()?.makeJSON())
        try json.set(Fields.points_earned, pointsEarned)
        try json.set(Fields.createdAt, self.createdAt?.timeIntervalSince1970)
        
        return json
    }
}

extension Transaction {
    var user: Parent<Transaction, User> {
        return parent(id: userId)
    }
    
    var merchant: Parent<Transaction, Merchant> {
        return parent(id: merchantId)
    }
}

extension Transaction: ResponseRepresentable { }

extension Transaction: Timestampable { }


