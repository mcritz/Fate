//
//  TodoServer.swift
//  fateball
//
//  Created by Michael Critz on 6/12/18.
//
import FluentSQLite
import Vapor

extension Todo: SQLiteModel { }

/// Allows `Todo` to be used as a dynamic migration.
extension Todo: Migration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension Todo: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension Todo: Parameter { }
