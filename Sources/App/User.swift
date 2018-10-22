//
//  User.swift
//  App
//
//  Created by Sebastian on 10/22/18.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct User: Content, SQLiteModel, Migration {
    var id: Int?
    var username: String
    var password: String
}
