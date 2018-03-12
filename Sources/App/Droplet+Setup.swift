@_exported import Vapor
import AuthProvider

weak var drop: Droplet!

extension Droplet {
    
    /// A setup function for the droplet class
    public func setup() throws {
        drop = self
        
        
        try setupRoutes()
        seedData()
    }
    
    /// Seeds the database with mock data
    func seedData() {
        guard (try? User.count()) == 0 else { return }
        guard (try? Role.count()) == 0 else { return }

        
        let roleAdmin = Role(type: "admin")
        let roleUser = Role(type: "user")
        let roleMerchant = Role(type: "merchant")
        
        try? roleAdmin.save()
        try? roleUser.save()
        try? roleMerchant.save()
        
        
        let admin = try? User.register(email: "admin@a.dk", password: "123456", name: "Admin")
        admin?.roleId = roleAdmin.id
        
        let user = try? User.register(email: "user@a.dk", password: "123456", name: "User")
        user?.roleId = roleUser.id
        
        let merchant = try? User.register(email: "merchant@a.dk", password: "123456", name: "Merchant")
        merchant?.roleId = roleMerchant.id
        
        try? admin?.save()
        try? user?.save()
        try? merchant?.save()
        
        
        let nettoAddress = Address(street: "Nettovej 32", zip: "2000", city: "København", country: "Denmark")
        try? nettoAddress.save()
        let netto = Merchant(name: "Netto", userId: merchant!.id!, addressId: nettoAddress.id!, pointsPercentage: 0.02)
        try? netto.save()
        
        let kandasAddress = Address(street: "Strandbygade 32", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? kandasAddress.save()
        let kandas = Merchant(name: "Kandas Thai Takeaway", userId: merchant!.id!, addressId: kandasAddress.id!, pointsPercentage: 0.04)
        try? kandas.save()
        
        let bilkaAddress = Address(street: "Stormgade 16", zip: "6710", city: "Esbjerg N", country: "Denmark")
        try? bilkaAddress.save()
        let bilka = Merchant(name: "Bilka", userId: merchant!.id!, addressId: bilkaAddress.id!, pointsPercentage: 0.00)
        try? bilka.save()
        
        let nillersAddress = Address(street: "Strandbygade 76", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? nillersAddress.save()
        let nillers = Merchant(name: "Nillers Pølsevogn", userId: merchant!.id!, addressId: nillersAddress.id!, pointsPercentage: 0.10)
        try? nillers.save()
        
        let sevenElevenAddress = Address(street: "Togbane 11", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? sevenElevenAddress.save()
        let sevenEleven = Merchant(name: "7/11", userId: merchant!.id!, addressId: sevenElevenAddress.id!, pointsPercentage: 0.01)
        try? sevenEleven.save()
        
        let flammenAddress = Address(street: "Exnersgade 25", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? flammenAddress.save()
        let flammen = Merchant(name: "Flammen", userId: merchant!.id!, addressId: flammenAddress.id!, pointsPercentage: 0.04)
        try? flammen.save()
        
        let butcherAddress = Address(street: "Grådybet 71", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? butcherAddress.save()
        let butcher = Merchant(name: "Butcher", userId: merchant!.id!, addressId: butcherAddress.id!, pointsPercentage: 0.01)
        try? butcher.save()
        
        let mcdAddress = Address(street: "Centrum 2", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? mcdAddress.save()
        let mcd = Merchant(name: "Mcdonalds", userId: merchant!.id!, addressId: mcdAddress.id!, pointsPercentage: 0.02)
        try? mcd.save()
        
        let sunsetAddress = Address(street: "Storegade 114", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? sunsetAddress.save()
        let sunset = Merchant(name: "Sunset Boulevard", userId: merchant!.id!, addressId: sunsetAddress.id!, pointsPercentage: 0.07)
        try? sunset.save()
        
        let burgerKingAddress = Address(street: "Jernbanegade 12", zip: "6700", city: "Esbjerg", country: "Denmark")
        try? burgerKingAddress.save()
        let burgerKing = Merchant(name: "Burger King", userId: merchant!.id!, addressId: burgerKingAddress.id!, pointsPercentage: 0.06)
        try? burgerKing.save()
        
        let kfcAddress = Address(street: "Strøget 22", zip: "2000", city: "København", country: "Denmark")
        try? kfcAddress.save()
        let kfc = Merchant(name: "Kentucky Fried Chicken", userId: merchant!.id!, addressId: kfcAddress.id!, pointsPercentage: 0.02)
        try? kfc.save()
    }
}
