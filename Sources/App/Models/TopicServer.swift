//
//  TopicServer.swift
//  App
//
//  Created by Critz, Michael on 1/30/19.
//

import Vapor
import FluentPostgreSQL

extension Topic: PostgreSQLModel {}
extension Topic: Migration {}
extension Topic: Content {}
extension Topic: Parameter {}
