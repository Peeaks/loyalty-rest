import Vapor
import FluentProvider

///Defines the users access levels and restrictions.
final class Address: Model {
    
    let storage = Storage()
    
    /**
     Enum which contains the database rows
     */
    enum Fields: String {
        ///Unique ID
        case id
        ///street as a String
        case street
        ///zip as a String
        case zip
        ///city as a String
        case city
        ///country as a String
        case country
    }
    
    var street: String
    var zip: String
    var city: String
    var country: String
    
    init(row: Row) throws {
        self.street = try row.get(Fields.street)
        self.zip = try row.get(Fields.zip)
        self.city = try row.get(Fields.city)
        self.country = try row.get(Fields.country)
    }
    
    init(street: String, zip: String, city: String, country: String) {
        self.street = street
        self.zip = zip
        self.city = city
        self.country = country
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Fields.street, street)
        try row.set(Fields.zip, zip)
        try row.set(Fields.city, city)
        try row.set(Fields.country, country)
        
        return row
    }
}

// MARK: Preparation

extension Address: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.id()
            table.string(Fields.street, optional: false)
            table.string(Fields.zip, optional: false)
            table.string(Fields.city, optional: false)
            table.string(Fields.country, optional: false)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Address: JSONRepresentable {
    
    //Return Post as JSON
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Fields.id, id)
        try json.set(Fields.street, street)
        try json.set(Fields.zip, zip)
        try json.set(Fields.city, city)
        try json.set(Fields.country, country)
        
        return json
    }
}

extension Address: ResponseRepresentable { }

extension Address: Timestampable { }




