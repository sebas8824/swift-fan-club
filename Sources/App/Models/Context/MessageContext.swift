//
//  MessageContext.swift
//  App
//
//  Created by Sebastian on 10/22/18.
//

import Foundation
import Vapor

struct MessageContext: Codable {
    var username: String?
    var forum: Forum
    var message: Message
    var replies: [Message]
}
