//
//  ForumContext.swift
//  App
//
//  Created by Sebastian on 10/22/18.
//

import Foundation
import Vapor

struct ForumContext: Codable {
    var username: String?
    var forum: Forum
    var messages: [Message]
}
