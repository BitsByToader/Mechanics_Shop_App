import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }
    
    try app.register(collection: UsersController())
    try app.register(collection: OrdersController())
    try app.register(collection: BillsController())
    try app.register(collection: MechanicsController())
}
