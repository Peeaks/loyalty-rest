import Vapor
import FluentProvider
import Foundation

///Defines the users access levels and restrictions.
final class Point: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///Payer as a Identifier
        case user_id
        ///Merchant as a Identifier
        case merchant_id
        ///Merchant as a merchant
        case merchant
        ///Amount as a UInt64
        case amount
    }
    
    var amount: UInt64 // UInt64 because all amounts are in minor unit, i.e. øre or cent
    var merchantId: Identifier
    var userId: Identifier
    
    init(row: Row) throws {
        self.amount = try row.get(Fields.amount)
        self.merchantId = try row.get(Fields.merchant_id)
        self.userId = try row.get(Fields.user_id)
    }
    
    init(amount: UInt64, merchantId: Identifier, userId: Identifier) {
        self.amount = amount
        self.merchantId = merchantId
        self.userId = userId
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.amount, amount)
        try row.set(Fields.merchant_id, merchantId)
        try row.set(Fields.user_id, userId)
        
        return row
    }
}

// MARK: Preparation

extension Point: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.amount, optional: false)
            table.foreignId(for: Merchant.self)
            table.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Point: JSONRepresentable {
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.amount, amount)
        try json.set(Fields.merchant, self.merchant.get()?.makeJSON())
        
        return json
    }
}

extension Point {
    var user: Parent<Point, User> {
        return parent(id: userId)
    }
    
    var merchant: Parent<Point, Merchant> {
        return parent(id: merchantId)
    }
}

extension Point: ResponseRepresentable { }

extension Point: Timestampable { }


