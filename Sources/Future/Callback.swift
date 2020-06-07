//
//  Callback.swift
//  
//
//  Created by Markus Pfeifer on 07.06.20.
//

import Foundation



public typealias Callback<T> = (T) -> Void
public typealias Handler<T> = (Result<T, Error>) -> Void
