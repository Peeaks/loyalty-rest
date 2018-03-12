import Foundation
import Vapor
import AuthProvider

final class MerchantController {
    
    private let droplet: Droplet
    
    private var merchantRepository: MerchantRepositoryProtocol
    private var addressRepository: AddressRepositoryProtocol
    
    /// Initializes the MerchantController
    init(droplet: Droplet) {
        self.droplet = droplet
        self.merchantRepository = MerchantRepository()
        self.addressRepository = AddressRepository()
    }
    
    /// Adds the routes to the droplet
    func addRoutes() {
        droplet.tokenAuthed.get("merchants", handler: getAllMerchants )
        droplet.tokenAuthed.get("merchants", Int.parameter, handler: getMerchant)
        
        droplet.merchantAuthed.post("merchants", handler: createMerchant)
        droplet.merchantAuthed.put("merchants", Int.parameter, handler: updateMerchant)
        droplet.merchantAuthed.delete("merchants", Int.parameter, handler: deleteMerchant)
    }
    
    /**
     When consumers call 'POST' on '/merchants' with valid JSON
     construct and save the merchant.
     Only available with valid token and admin or merchant role.
     ```
     {
         "name": "Test Merchant",
         "pointsPercentage": 0.05,
         "address": {
             "street": "Testvej 123",
             "zip": "1234",
             "country": "Denmark",
             "city": "Testby"
         }
     }
     */
    func createMerchant(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.data["name"]?.string else {
            throw Abort(.badRequest, reason: "Please provide Name")
        }
        
        guard let pointsPercentage = request.data["pointsPercentage"]?.double else {
            throw Abort(.badRequest, reason: "Please provide Points Percentage")
        }
        
        guard let tempAddress = request.data["address"],
              let street = tempAddress["street"]?.string,
              let zip = tempAddress["zip"]?.string,
              let country = tempAddress["country"]?.string,
              let city = tempAddress["city"]?.string
        else {
            throw Abort(.badRequest, reason: "Please provide Address")
        }
        
        let address = try addressRepository.create(street: street, zip: zip, city: country, country: city)
        
        let loggedInUser = try request.user()
        
        let merchant = try merchantRepository.create(name: name, userId: loggedInUser.id!, addressId: address.id!, pointsPercentage: pointsPercentage)
        
        return merchant
    }
    
    /**
     When users call 'GET' on '/merchant'
     it should return an index of all available Merchants.
     Only available with valid token.
     */
    func getAllMerchants(request: Request) throws -> ResponseRepresentable {
        return try merchantRepository.getAll().makeJSON()
    }
    
    /**
     When users call 'GET' on '/merchant/:Id'
     it should return the Merchant with the specified Id.
     Only available with valid token.
     */
    func getMerchant(request: Request) throws -> ResponseRepresentable {
        let merchantId = try request.parameters.next(Int.self)
        
        guard let merchant = try merchantRepository.get(withId: merchantId) else {
            throw Abort(.badRequest, reason: "No merchant found with Id: \(merchantId)")
        }

        return try merchant.makeJSON()
    }
    
    /**
     When consumers call 'PUT' on '/merchant/:Id' with valid JSON
     read and modify the merchant.
     Only available with valid token and admin or merchant role.
     ```
     {
         "name": "Test Merchant",
         "pointsPercentage": 0.05,
         "address": {
         "street": "Testvej 123",
         "zip": "1234",
         "country": "Denmark",
         "city": "Testby"
         }
     }
     */
    func updateMerchant(request: Request) throws -> ResponseRepresentable {
        let merchantId = try request.parameters.next(Int.self)
        
        guard let merchant = try merchantRepository.get(withId: merchantId) else {
            throw Abort(.badRequest, reason: "No merchant found with Id: \(merchantId)")
        }
        
        let merchantOwner = try merchant.owner.get()
        let user = try request.user()
        
        if merchantOwner?.id != user.id {
            throw Abort(.badRequest, reason: "You can only update merchants that you created yourself")
        }
        
        guard let name = request.data["name"]?.string else {
            throw Abort(.badRequest, reason: "Please provide Name")
        }
        
        guard let pointsPercentage = request.data["pointsPercentage"]?.double else {
            throw Abort(.badRequest, reason: "Please provide Points Percentage")
        }
        
        guard let tempAddress = request.data["address"],
            let street = tempAddress["street"]?.string,
            let zip = tempAddress["zip"]?.string,
            let country = tempAddress["country"]?.string,
            let city = tempAddress["city"]?.string
            else {
                throw Abort(.badRequest, reason: "Please provide Address")
        }
        
        let updatedAddress = try addressRepository.update(addressId: merchant.addressId, street: street, zip: zip, country: country, city: city)
        
        guard let updatedMerchant = try merchantRepository.update(merchantId: merchant.id!, name: name, pointsPercentage: pointsPercentage) else {
            throw Abort(.badRequest, reason: "Error updating Merchant with id \(merchant.id!)")
        }
        
        return updatedMerchant
    }
    
    /**
     When consumers call 'DELETE' on '/merchant/:Id'
     deletes the merchant if found.
     Only available with valid token and admin or merchant role.
     */
    func deleteMerchant(request: Request) throws -> ResponseRepresentable {
        let merchantId = try request.parameters.next(Int.self)
        guard let merchant = try merchantRepository.get(withId: merchantId) else {
            throw Abort(.badRequest, reason: "No merchant found with Id: \(merchantId)")
        }
        
        let merchantOwner = try merchant.owner.get()
        let user = try request.user()
        
        if (merchantOwner?.id != user.id) {
            throw Abort(.badRequest, reason: "You can only delete merchants that you created yourself")
        }
        
        try merchantRepository.delete(merchantId: merchantId)
        
        return try JSON(node :["success": true])
    }
    
}
