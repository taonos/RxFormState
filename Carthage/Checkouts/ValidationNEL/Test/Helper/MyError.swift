//
//  MyError.swift
//  ValidationNEL
//
//  Created by Lance Zhu on 2016-07-07.
//  Copyright © 2016 Lance Zhu. All rights reserved.
//

import Foundation


struct MyError : Equatable {
    let message: String
}

func ==(lhs: MyError, rhs: MyError) -> Bool {
    return lhs.message == rhs.message
}