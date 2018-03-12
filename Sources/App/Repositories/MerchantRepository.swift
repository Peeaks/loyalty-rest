import Foundation
import Vapor

final class MerchantRepository { }

extension MerchantRepository: MerchantRepositoryProtocol {
    
    /// Returns all Merchants found
    func getAll() throws -> [Merchant] {
        return try Merchant.makeQuery().all()
    }
    
    /**
     Returns the Merchant with the id
     - parameters:
     - id: id as Int
     */
    func get(withId id: Int) throws -> Merchant? {
        return try Merchant.find(id)
    }
    
    /**
     Creates a Merchant
     - parameters:
     - name: name as String
     - userId: userId as Identifier
     - addressId: addressId as Identifier
     - pointsPercentage: pointsPercentage as Double
     */
    func create(name: String, userId: Identifier, addressId: Identifier, pointsPercentage: Double) throws -> Merchant {
        let merchant = Merchant(name: name, userId: userId, addressId: addressId, pointsPercentage: pointsPercentage)
        try merchant.save()
        return merchant
    }
    
    /**
     Updates a Merchant
     - parameters:
     - merchantId: merchantId as Identifier
     - name: name as String
     - pointsPercentage: pointsPercentage as Double
     */
    func update(merchantId: Identifier, name: String, pointsPercentage: Double) throws -> Merchant? {
        let merchant = try Merchant.find(merchantId)
        
        merchant?.name = name
        merchant?.pointsPercentage = pointsPercentage
        
        try merchant?.save()
        return merchant
    }
    
    /**
     Deletes a Merchant
     - parameters:
     - merchantId: merchantId as Int
     */
    func delete(merchantId: Int) throws {
        try Merchant.find(merchantId)?.delete()
    }
    
    
}
