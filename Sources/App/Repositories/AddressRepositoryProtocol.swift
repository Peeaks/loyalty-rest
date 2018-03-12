import Foundation
import Vapor

protocol AddressRepositoryProtocol: class {
    
    /**
     Returns the Address with the sent in Id if found
     - parameters:
     - id: id as Identifier
     */
    func get(withId id: Identifier) throws -> Address?
    
    /**
     Creates an Address
     - parameters:
     - street: street as String
     - zip: zip as String
     - city: city as String
     - country: country as String
     */
    func create(street: String, zip: String, city: String, country: String) throws -> Address
    
    /**
     Updates an Address
     - parameters:
     - addressId: id as Identifier
     - street: street as String
     - zip: zip as String
     - city: city as String
     - country: country as String
     */
    func update(addressId: Identifier, street: String, zip: String, country: String, city: String) throws -> Address?
    
    /**
     Deletes an Address
     - parameters:
     - addressId: id as Identifier
     */
    func delete(addressId: Identifier) throws
}
