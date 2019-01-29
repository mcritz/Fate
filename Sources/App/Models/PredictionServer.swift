//
//  PredictionServer.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import FluentPostgreSQL
import Vapor

extension Prediction: PostgreSQLUUIDModel { }

extension Prediction: Migration { }

extension Prediction: Content { }

extension Prediction: Parameter { }
