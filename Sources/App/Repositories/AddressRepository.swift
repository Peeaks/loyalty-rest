import Foundation
import Vapor

final class AddressRepository { }

extension AddressRepository: AddressRepositoryProtocol {

    /**
     Returns the Address with the sent in Id if found
     - parameters:
     - id: id as Identifier
     */
    func get(withId id: Identifier) throws -> Address? {
        return try Address.find(id)
    }
    
    /**
     Creates an Address
     - parameters:
     - street: street as String
     - zip: zip as String
     - city: city as String
     - country: country as String
     */
    func create(street: String, zip: String, city: String, country: String) throws -> Address {
        let address = Address(street: street, zip: zip, city: city, country: country)
        try address.save()
        return address
    }
    
    /**
     Updates an Address
     - parameters:
     - addressId: id as Identifier
     - street: street as String
     - zip: zip as String
     - city: city as String
     - country: country as String
     */
    func update(addressId: Identifier, street: String, zip: String, country: String, city: String) throws -> Address? {
        let address = try Address.find(addressId)
        
        address?.street = street
        address?.zip = zip
        address?.country = country
        address?.city = city
        
        try address?.save()
        
        return address
    }
    
    /**
     Deletes an Address
     - parameters:
     - addressId: id as Identifier
     */
    func delete(addressId: Identifier) throws {
        try Address.find(addressId)?.delete()
    }
    
}
