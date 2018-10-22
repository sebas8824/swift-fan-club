import Vapor
import Leaf
import Fluent
import FluentSQLite
import Crypto

public func routes(_ router: Router) throws {
    router.get("setup") { req -> String in
        /*let item1 = Forum(id: 1, name: "Artist's songs")
        let item2 = Forum(id: 2, name: "Artist's Albums")
        let item3 = Forum(id: 3, name: "Artist's Concerts")*/
        
        let item1 = Message(id: 1, forum: 1, title: "Welcome", body:
            "Hello!", parent: 0, user: "sebas8824", date: Date())
        let item2 = Message(id: 2, forum: 1, title: "Second post",
                            body: "Hello!", parent: 0, user: "sebas8824", date: Date())
        let item3 = Message(id: 3, forum: 1, title: "Test reply", body:
            "Yay!", parent: 1, user: "sebas8824", date: Date())
        _ = item1.create(on: req)
        _ = item2.create(on: req)
        _ = item3.create(on: req)
        return "OK"
    }
    
    router.get { req -> Future<View> in
        return Forum.query(on: req).all().flatMap(to: View.self) {
            forums in
            let context = HomeContext(username: getUsername(req), forums: forums)
            return try req.view().render("home", context)
        }
    }
    
    router.get("forum", Int.parameter) { req -> Future<View> in
        let forumID = try req.parameters.next(Int.self)
        
        return try Forum.find(forumID, on: req).flatMap(to: View.self) {
            forum in
            guard let forum = forum else {
                throw Abort(.notFound)
            }
            
            /* Finds all the top-level messages that belong to this forum*/
            let query = try Message.query(on: req)
                .filter(\.forum == forum.id!)
                .filter(\.parent == 0)
                .all()
            
            return query.flatMap(to: View.self) { messages in
                let context = ForumContext(username: getUsername(req), forum: forum, messages: messages)
                return try req.view().render("forum", context)
            }
        }
    }
    
    router.get("forum", Int.parameter, Int.parameter) { req -> Future<View> in
        let forumID = try req.parameters.next(Int.self)
        let messageID = try req.parameters.next(Int.self)
        
        /* Look up in Forums what was requested */
        return try Forum.find(forumID, on: req).flatMap(to: View.self) {
            forum in
            guard let forum = forum else { throw Abort(.notFound) }
            
            return try Message.find(messageID, on: req).flatMap(to: View.self) {
                message in
                guard let message = message else { throw Abort(.notFound) }
                
                let query = try Message.query(on: req)
                    .filter(\.parent == message.id!)
                    .all()
                
                return query.flatMap(to: View.self) { replies in
                    let context = MessageContext(username: getUsername(req), forum: forum, message: message, replies: replies)
                    return try req.view().render("message", context)
                }
            }
        }        
    }
    
    router.get("users", "login") { req -> Future<View> in
        return try req.view().render("users-login")
    }
    
    router.post(User.self, at: "users", "login") { req, user -> Future<View> in
        return try User.query(on: req)
            .filter(\.username == user.username)
            .first().flatMap(to: View.self) { existing in
                if let existing = existing {
                    if try BCrypt.verify(user.password, created: existing.password) {
                        let session = try req.session()
                        session["username"] = existing.username
                        
                        return try req.view().render("users-welcome")
                    }
                }
                
                return try req.view().render("users-login", ["error": "true"])
        }
    }
    
    router.get("users", "create") { req -> Future<View> in
        return try req.view().render("users-create")
    }
    
    router.post("users", "create") { req -> Future<View> in
        /* Creating and decoding an user instance from the form */
        var user = try req.content.syncDecode(User.self)
        
        return try User.query(on: req)
            .filter(\.username == user.username)
            .first().flatMap(to: View.self) { existing in
                /* If there is no username already taken, it is needed to encrypt the password */
                if existing == nil {
                    user.password = try BCrypt.hash(user.password)
                    /* Saving the user instance on the DB and redirecting to the users-welcome page */
                    return user.save(on: req).flatMap(to: View.self) { user in
                        return try req.view().render("users-welcome")
                    }
                } else {
                /* Otherwise we send and error flag for the page to render its proper message to the user */
                    return try req.view().render("users-create", ["error": "true"])
                }
            }
    }
    
    router.post("forum", Int.parameter ,use: postOrReply)
    
    router.post("forum", Int.parameter, Int.parameter, use: postOrReply)
}

func getUsername(_ req: Request) -> String? {
    let session = try? req.session()
    return session?["username"]
}

func postOrReply(req: Request) throws -> Future<Response> {
    guard let username = getUsername(req) else {
        throw Abort(.unauthorized)
    }
    
    let forumID = try req.parameters.next(Int.self)
    let parentID = (try? req.parameters.next(Int.self)) ?? 0
    let title: String = try req.content.syncGet(at: "title")
    let body: String = try req.content.syncGet(at: "body")
    let post = Message(id: nil, forum: forumID, title: title, body: body, parent: parentID, user: username, date: Date())
    
    return post.save(on: req).map(to: Response.self) { post in
        if parentID == 0 {
            return req.redirect(to: "/forum/\(forumID)/\(post.id!)")
        } else {
            return req.redirect(to: "/forum/\(forumID)/\(parentID)")
        }
    }
}
