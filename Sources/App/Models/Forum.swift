//
//  Forum.swift
//  App
//
//  Created by Sebastian on 10/14/18.
//

import Foundation
import Fluent
import FluentSQLite
import Vapor

struct Forum: Content, SQLiteModel, Migration {
    var id: Int?
    var name: String
}
