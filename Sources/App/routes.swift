import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("setup") { req -> String in
        let item1 = Forum(id: 1, name: "Artist's songs")
        let item2 = Forum(id: 2, name: "Artist's Albums")
        let item3 = Forum(id: 3, name: "Artist's Concerts")
        _ = item1.create(on: req)
        _ = item2.create(on: req)
        _ = item3.create(on: req)
        return "OK"
    }
}
