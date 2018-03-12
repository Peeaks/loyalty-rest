import FluentProvider
import MySQLProvider
import AuthProvider

weak var config: Config!

extension Config {
    
    public func setup() throws {
        config = self
        
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
        try setupPreparations()
    }
    
    private func setupProviders() throws {
        addConfigurable(middleware: HerokuHttpsMiddleware.init, name: "heroku")
        addConfigurable(middleware: LogMiddleware(), name: "log")
        
        try addProvider(AuthProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
    }
    
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(AccessToken.self)
        preparations.append(Transaction.self)
        preparations.append(Merchant.self)
        preparations.append(Address.self)
        preparations.append(Role.self)
        preparations.append(Log.self)
        preparations.append(Point.self)
    }
}
