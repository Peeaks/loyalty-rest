import Vapor
import FluentProvider

///Defines the users access levels and restrictions.
final class Merchant: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///name as a String
        case name
        ///user_id as a Identifier
        case user_id
        ///address_id as a Identifier
        case address_id
        /// address as a Address
        case address
        ///points_percentage as a Double
        case points_percentage
    }
    
    var name: String
    var userId: Identifier
    var addressId: Identifier
    var pointsPercentage: Double
    
    init(row: Row) throws {
        self.name = try row.get(Fields.name)
        self.userId = try row.get(Fields.user_id)
        self.addressId = try row.get(Fields.address_id)
        self.pointsPercentage = try row.get(Fields.points_percentage)
    }
    
    init(name: String, userId: Identifier, addressId: Identifier, pointsPercentage: Double) {
        self.name = name
        self.userId = userId
        self.addressId = addressId
        self.pointsPercentage = pointsPercentage
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.name, name)
        try row.set(Fields.user_id, userId)
        try row.set(Fields.address_id, addressId)
        try row.set(Fields.points_percentage, pointsPercentage)
        
        return row
    }
}

// MARK: Preparation

extension Merchant: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.name, optional: false)
            table.foreignId(for: User.self)
            table.foreignId(for: Address.self)
            table.string(Fields.points_percentage)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Merchant: JSONRepresentable {
    
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.name, name)
        try json.set(Fields.address, self.address.get()?.makeJSON())
        try json.set(Fields.points_percentage, pointsPercentage)
        
        return json
    }
}

extension Merchant {
    var transactions: Children<Merchant, Transaction> {
        return children()
    }
    
    var address: Parent<Merchant, Address> {
        return parent(id: addressId) 
    }
    
    var owner: Parent<Merchant, User> {
        return parent(id: userId)
    }
}

extension Merchant: ResponseRepresentable { }

extension Merchant: Timestampable { }

extension Merchant: SoftDeletable { }

