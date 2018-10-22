//
//  Message.swift
//  App
//
//  Created by Sebastian on 10/22/18.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Message: Content, SQLiteModel, Migration {
    var id: Int?
    var forum: Int
    var title: String
    var body: String
    var parent: Int
    var user: String
    var date: Date

}
