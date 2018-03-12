import Foundation
import Vapor

protocol MerchantRepositoryProtocol: class {
    
    /// Returns all Merchants found
    func getAll() throws -> [Merchant]
    
    /**
     Returns the Merchant with the id
     - parameters:
     - id: id as Int
     */
    func get(withId id: Int) throws -> Merchant?
    
    /**
     Creates a Merchant
     - parameters:
     - name: name as String
     - userId: userId as Identifier
     - addressId: addressId as Identifier
     - pointsPercentage: pointsPercentage as Double
     */
    func create(name: String, userId: Identifier, addressId: Identifier, pointsPercentage: Double) throws -> Merchant
    
    /**
     Updates a Merchant
     - parameters:
     - merchantId: merchantId as Identifier
     - name: name as String
     - pointsPercentage: pointsPercentage as Double
     */
    func update(merchantId: Identifier, name: String, pointsPercentage: Double) throws -> Merchant?
    
    /**
     Deletes a Merchant
     - parameters:
     - merchantId: merchantId as Int
     */
    func delete(merchantId: Int) throws
}
