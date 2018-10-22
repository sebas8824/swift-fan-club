//
//  HomeContext.swift
//  App
//
//  Created by Sebastian on 10/22/18.
//

import Foundation
import Vapor

struct HomeContext: Codable {
    var username: String?
    var forums: [Forum]
}
