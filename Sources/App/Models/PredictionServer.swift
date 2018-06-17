//
//  PredictionServer.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import FluentSQLite
import Vapor

extension Prediction: SQLiteModel { }

extension Prediction: Migration { }

extension Prediction: Content { }

extension Prediction: Parameter { }
