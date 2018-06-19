//
//  PredictionServer.swift
//  App
//
//  Created by Michael Critz on 6/16/18.
//

import FluentMySQL
import Vapor

extension Prediction: MySQLModel { }

extension Prediction: Migration { }

extension Prediction: Content { }

extension Prediction: Parameter { }
